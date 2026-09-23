package com.jbforsaken.web.monitoring;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/** Minimal Source Engine Query protocol responder, loopback-only, for tests. */
public final class FakeA2sServer implements AutoCloseable {

    private final DatagramSocket socket;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private volatile boolean running = true;
    private final CountDownLatch ready = new CountDownLatch(1);
    private final boolean requireInfoChallenge;
    private final AtomicInteger infoRequests = new AtomicInteger();

    private static final byte[] CHALLENGE = {1, 2, 3, 4};
    /** Header (4) + type (1) + "Source Engine Query\0" (20): where an appended challenge starts. */
    private static final int INFO_PAYLOAD_END = 5 + "Source Engine Query\0".length();

    /** Behaves like a current CS2 server: A2S_INFO requires the challenge handshake. */
    public FakeA2sServer() throws IOException {
        this(true);
    }

    /**
     * @param requireInfoChallenge false emulates a legacy server that answers the first
     *     A2S_INFO directly with the info payload (no challenge round-trip).
     */
    public FakeA2sServer(boolean requireInfoChallenge) throws IOException {
        this.requireInfoChallenge = requireInfoChallenge;
        socket = new DatagramSocket(new InetSocketAddress(InetAddress.getLoopbackAddress(), 0));
        executor.submit(this::runLoop);
        try {
            ready.await(1, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    public int getPort() {
        return socket.getLocalPort();
    }

    /** Number of A2S_INFO (0x54) requests received so far. */
    public int getInfoRequestCount() {
        return infoRequests.get();
    }

    private static byte[] challengePacket() {
        return new byte[] {(byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, 0x41,
                           CHALLENGE[0], CHALLENGE[1], CHALLENGE[2], CHALLENGE[3]};
    }

    private void runLoop() {
        byte[] buffer = new byte[1400];
        ready.countDown();
        while (running) {
            try {
                DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
                socket.receive(packet);
                byte[] request = Arrays.copyOf(packet.getData(), packet.getLength());

                if (request.length >= 5 && (request[4] & 0xFF) == 0x54) {
                    infoRequests.incrementAndGet();
                    // Post-Dec-2020 Source/Source 2 behavior: an A2S_INFO without the
                    // challenge appended gets a challenge packet (type 'A'), not the info.
                    boolean hasCorrectChallenge = request.length == INFO_PAYLOAD_END + 4
                        && Arrays.equals(request, INFO_PAYLOAD_END, INFO_PAYLOAD_END + 4, CHALLENGE, 0, 4);
                    byte[] response = (requireInfoChallenge && !hasCorrectChallenge)
                        ? challengePacket()
                        : buildInfoResponse();
                    socket.send(new DatagramPacket(response, response.length, packet.getAddress(), packet.getPort()));
                } else if (request.length >= 5 && (request[4] & 0xFF) == 0x55) {
                    boolean hasRealChallenge = request.length >= 9
                        && !(request[5] == (byte) 0xFF && request[6] == (byte) 0xFF
                             && request[7] == (byte) 0xFF && request[8] == (byte) 0xFF);
                    if (!hasRealChallenge) {
                        byte[] challenge = challengePacket();
                        socket.send(new DatagramPacket(challenge, challenge.length, packet.getAddress(), packet.getPort()));
                    } else {
                        byte[] response = buildPlayerResponse();
                        socket.send(new DatagramPacket(response, response.length, packet.getAddress(), packet.getPort()));
                    }
                }
            } catch (IOException ex) {
                running = false;
            }
        }
    }

    private static byte[] buildInfoResponse() {
        byte[] name = cstring("JBFORSAKEN Test Server");
        byte[] map = cstring("jb_test_map");
        byte[] folder = cstring("csgo");
        byte[] game = cstring("Counter-Strike 2");

        ByteBuffer buffer = ByteBuffer
            .allocate(5 + 1 + name.length + map.length + folder.length + game.length + 2 + 7)
            .order(ByteOrder.LITTLE_ENDIAN);
        buffer.put((byte) 0xFF).put((byte) 0xFF).put((byte) 0xFF).put((byte) 0xFF).put((byte) 0x49);
        buffer.put((byte) 17);
        buffer.put(name).put(map).put(folder).put(game);
        buffer.putShort((short) 730);
        buffer.put((byte) 5).put((byte) 32).put((byte) 0);
        buffer.put((byte) 'd').put((byte) 'l').put((byte) 0).put((byte) 1);
        return buffer.array();
    }

    private static byte[] buildPlayerResponse() {
        byte[] alice = cstring("Alice");
        byte[] bob = cstring("Bob");

        ByteBuffer buffer = ByteBuffer
            .allocate(5 + 1 + (1 + alice.length + 4 + 4) + (1 + bob.length + 4 + 4))
            .order(ByteOrder.LITTLE_ENDIAN);
        buffer.put((byte) 0xFF).put((byte) 0xFF).put((byte) 0xFF).put((byte) 0xFF).put((byte) 0x44);
        buffer.put((byte) 2);
        buffer.put((byte) 0).put(alice).putInt(12).putFloat(305.5f);
        buffer.put((byte) 1).put(bob).putInt(3).putFloat(40.0f);
        return buffer.array();
    }

    private static byte[] cstring(String value) {
        byte[] text = value.getBytes(StandardCharsets.UTF_8);
        byte[] result = new byte[text.length + 1];
        System.arraycopy(text, 0, result, 0, text.length);
        return result;
    }

    @Override
    public void close() {
        running = false;
        socket.close();
        executor.shutdown();
        try {
            executor.awaitTermination(1, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
