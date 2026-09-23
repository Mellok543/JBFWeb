package com.jbforsaken.web.monitoring;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
public class UdpA2sClient implements A2sClient {

    private static final int TIMEOUT_MS = 2000;

    private static final byte TYPE_CHALLENGE = 0x41; // 'A'
    private static final byte TYPE_INFO = 0x49;      // 'I'

    @Override
    public Optional<A2sInfoResult> queryInfo(String host, int port) {
        try (DatagramSocket socket = new DatagramSocket()) {
            socket.setSoTimeout(TIMEOUT_MS);
            InetAddress address = InetAddress.getByName(host);

            byte[] response = sendAndReceive(socket, address, port, buildInfoRequest(null));

            // Since Valve's Dec 2020 anti-reflection change, servers may answer the first
            // A2S_INFO with a challenge (FF FF FF FF 41 <4 bytes>) instead of the info.
            // Resend once with the challenge appended; never loop.
            if (hasType(response, TYPE_CHALLENGE)) {
                if (response.length < 9) {
                    return Optional.empty();
                }
                byte[] challenge = Arrays.copyOfRange(response, 5, 9);
                response = sendAndReceive(socket, address, port, buildInfoRequest(challenge));
            }

            if (!hasType(response, TYPE_INFO)) {
                return Optional.empty();
            }
            return Optional.of(parseInfoResponse(response));
        } catch (IOException | IndexOutOfBoundsException ex) {
            return Optional.empty();
        }
    }

    private static byte[] sendAndReceive(DatagramSocket socket, InetAddress address, int port, byte[] request)
            throws IOException {
        socket.send(new DatagramPacket(request, request.length, address, port));

        byte[] buffer = new byte[1400];
        DatagramPacket response = new DatagramPacket(buffer, buffer.length);
        socket.receive(response);
        return Arrays.copyOf(response.getData(), response.getLength());
    }

    /** Single-packet header (FF FF FF FF) followed by the given response type byte. */
    private static boolean hasType(byte[] data, byte type) {
        return data.length >= 5
            && data[0] == (byte) 0xFF && data[1] == (byte) 0xFF
            && data[2] == (byte) 0xFF && data[3] == (byte) 0xFF
            && data[4] == type;
    }

    @Override
    public List<A2sPlayerInfo> queryPlayers(String host, int port) {
        try (DatagramSocket socket = new DatagramSocket()) {
            socket.setSoTimeout(TIMEOUT_MS);
            InetAddress address = InetAddress.getByName(host);

            byte[] challenge = requestChallenge(socket, address, port);
            if (challenge == null) {
                return List.of();
            }

            byte[] request = new byte[9];
            request[0] = (byte) 0xFF;
            request[1] = (byte) 0xFF;
            request[2] = (byte) 0xFF;
            request[3] = (byte) 0xFF;
            request[4] = 0x55;
            System.arraycopy(challenge, 0, request, 5, 4);

            socket.send(new DatagramPacket(request, request.length, address, port));

            byte[] buffer = new byte[1400];
            DatagramPacket response = new DatagramPacket(buffer, buffer.length);
            socket.receive(response);

            return parsePlayerResponse(Arrays.copyOf(response.getData(), response.getLength()));
        } catch (IOException | IndexOutOfBoundsException ex) {
            return List.of();
        }
    }

    private byte[] requestChallenge(DatagramSocket socket, InetAddress address, int port) throws IOException {
        byte[] request = {(byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, 0x55,
                           (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF};
        socket.send(new DatagramPacket(request, request.length, address, port));

        byte[] buffer = new byte[32];
        DatagramPacket response = new DatagramPacket(buffer, buffer.length);
        socket.receive(response);

        if (response.getLength() < 9 || buffer[4] != 0x41) {
            return null;
        }
        return Arrays.copyOfRange(buffer, 5, 9);
    }

    /** @param challenge 4 challenge bytes to append after the payload, or null for the initial request. */
    private static byte[] buildInfoRequest(byte[] challenge) {
        byte[] query = "Source Engine Query\0".getBytes(StandardCharsets.US_ASCII);
        int challengeLength = challenge == null ? 0 : challenge.length;
        byte[] request = new byte[5 + query.length + challengeLength];
        request[0] = (byte) 0xFF;
        request[1] = (byte) 0xFF;
        request[2] = (byte) 0xFF;
        request[3] = (byte) 0xFF;
        request[4] = 0x54;
        System.arraycopy(query, 0, request, 5, query.length);
        if (challenge != null) {
            System.arraycopy(challenge, 0, request, 5 + query.length, challengeLength);
        }
        return request;
    }

    private A2sInfoResult parseInfoResponse(byte[] data) {
        ByteReader reader = new ByteReader(data, 5);
        reader.skip(1); // protocol byte
        String name = reader.readCString();
        String map = reader.readCString();
        String folder = reader.readCString();
        String game = reader.readCString();
        reader.skip(2); // appid
        int players = reader.readUnsignedByte();
        int maxPlayers = reader.readUnsignedByte();
        return new A2sInfoResult(name, map, folder, game, players, maxPlayers);
    }

    private List<A2sPlayerInfo> parsePlayerResponse(byte[] data) {
        ByteReader reader = new ByteReader(data, 5);
        int count = reader.readUnsignedByte();
        List<A2sPlayerInfo> players = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            reader.skip(1); // player index
            String name = reader.readCString();
            int score = reader.readInt32LE();
            float duration = reader.readFloat32LE();
            players.add(new A2sPlayerInfo(name, score, duration));
        }
        return players;
    }

    private static final class ByteReader {
        private final byte[] data;
        private int offset;

        ByteReader(byte[] data, int offset) {
            this.data = data;
            this.offset = offset;
        }

        void skip(int count) {
            offset += count;
        }

        int readUnsignedByte() {
            return data[offset++] & 0xFF;
        }

        String readCString() {
            int start = offset;
            while (data[offset] != 0) {
                offset++;
            }
            String value = new String(data, start, offset - start, StandardCharsets.UTF_8);
            offset++;
            return value;
        }

        int readInt32LE() {
            int value = ByteBuffer.wrap(data, offset, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();
            offset += 4;
            return value;
        }

        float readFloat32LE() {
            float value = ByteBuffer.wrap(data, offset, 4).order(ByteOrder.LITTLE_ENDIAN).getFloat();
            offset += 4;
            return value;
        }
    }
}
