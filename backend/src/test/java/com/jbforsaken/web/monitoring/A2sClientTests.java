package com.jbforsaken.web.monitoring;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.Test;

class A2sClientTests {

    @Test
    void queryInfo_parsesServerInfo() throws IOException {
        // Default FakeA2sServer behaves like a current CS2 server: the first A2S_INFO is
        // answered with a challenge, and only the challenge-carrying retry gets the info.
        try (FakeA2sServer fakeServer = new FakeA2sServer()) {
            UdpA2sClient client = new UdpA2sClient();

            Optional<A2sInfoResult> result = client.queryInfo("127.0.0.1", fakeServer.getPort());

            assertThat(result).isPresent();
            assertThat(result.get().name()).isEqualTo("JBFORSAKEN Test Server");
            assertThat(result.get().map()).isEqualTo("jb_test_map");
            assertThat(result.get().game()).isEqualTo("Counter-Strike 2");
            assertThat(result.get().players()).isEqualTo(5);
            assertThat(result.get().maxPlayers()).isEqualTo(32);
            assertThat(fakeServer.getInfoRequestCount()).isEqualTo(2);
        }
    }

    @Test
    void queryInfo_whenServerAnswersWithoutChallenge_parsesInSingleRoundTrip() throws IOException {
        try (FakeA2sServer fakeServer = new FakeA2sServer(false)) {
            UdpA2sClient client = new UdpA2sClient();

            Optional<A2sInfoResult> result = client.queryInfo("127.0.0.1", fakeServer.getPort());

            assertThat(result).isPresent();
            assertThat(result.get().name()).isEqualTo("JBFORSAKEN Test Server");
            assertThat(fakeServer.getInfoRequestCount()).isEqualTo(1);
        }
    }

    @Test
    void queryInfo_whenServerKeepsChallenging_returnsEmptyInsteadOfLooping() throws Exception {
        byte[] challenge = {(byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, 0x41, 9, 9, 9, 9};

        try (DatagramSocket server = new DatagramSocket(new InetSocketAddress(InetAddress.getLoopbackAddress(), 0))) {
            ExecutorService executor = Executors.newSingleThreadExecutor();
            executor.submit(() -> {
                try {
                    byte[] buffer = new byte[1400];
                    while (!server.isClosed()) {
                        DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
                        server.receive(packet);
                        server.send(new DatagramPacket(challenge, challenge.length, packet.getAddress(), packet.getPort()));
                    }
                } catch (IOException e) {
                    // Expected when server closes
                }
            });

            Optional<A2sInfoResult> result = new UdpA2sClient().queryInfo("127.0.0.1", server.getLocalPort());

            assertThat(result).isEmpty();
            server.close();
            executor.shutdown();
            executor.awaitTermination(1, TimeUnit.SECONDS);
        }
    }

    @Test
    void queryInfo_whenResponseTypeIsUnexpected_returnsEmpty() throws Exception {
        // A well-formed A2S_PLAYER-style header (type 'D') must not be parsed as info.
        byte[] wrongType = {(byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, 0x44,
                            0x11, 'a', 0, 'b', 0, 'c', 0, 'd', 0, 0, 0, 5, 32};

        try (DatagramSocket server = new DatagramSocket(new InetSocketAddress(InetAddress.getLoopbackAddress(), 0))) {
            ExecutorService executor = Executors.newSingleThreadExecutor();
            executor.submit(() -> {
                try {
                    byte[] buffer = new byte[1400];
                    DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
                    server.receive(packet);
                    server.send(new DatagramPacket(wrongType, wrongType.length, packet.getAddress(), packet.getPort()));
                } catch (IOException e) {
                    // Expected when server closes
                }
            });

            Optional<A2sInfoResult> result = new UdpA2sClient().queryInfo("127.0.0.1", server.getLocalPort());

            assertThat(result).isEmpty();
            executor.shutdown();
            executor.awaitTermination(1, TimeUnit.SECONDS);
        }
    }

    @Test
    void queryPlayers_handlesChallengeHandshakeAndParsesPlayers() throws IOException {
        try (FakeA2sServer fakeServer = new FakeA2sServer()) {
            UdpA2sClient client = new UdpA2sClient();

            List<A2sPlayerInfo> players = client.queryPlayers("127.0.0.1", fakeServer.getPort());

            assertThat(players).hasSize(2);
            assertThat(players).anySatisfy(p -> {
                assertThat(p.name()).isEqualTo("Alice");
                assertThat(p.score()).isEqualTo(12);
            });
            assertThat(players).anySatisfy(p -> {
                assertThat(p.name()).isEqualTo("Bob");
                assertThat(p.score()).isEqualTo(3);
            });
        }
    }

    @Test
    void queryInfo_returnsEmptyWhenServerUnreachable() {
        UdpA2sClient client = new UdpA2sClient();

        Optional<A2sInfoResult> result = client.queryInfo("127.0.0.1", 1);

        assertThat(result).isEmpty();
    }

    @Test
    void queryInfo_returnsEmptyOnMalformedResponse() throws IOException, InterruptedException {
        // Create a simple UDP server that sends truncated/malformed response
        try (DatagramSocket server = new DatagramSocket(new InetSocketAddress(InetAddress.getLoopbackAddress(), 0))) {
            int port = server.getLocalPort();
            ExecutorService executor = Executors.newSingleThreadExecutor();

            // Start server thread that sends malformed response
            executor.submit(() -> {
                try {
                    byte[] buffer = new byte[1400];
                    DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
                    server.receive(packet);

                    // Send malformed response: missing null terminators, truncated
                    byte[] malformedResponse = {(byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0x49, 0x11};
                    server.send(new DatagramPacket(malformedResponse, malformedResponse.length, packet.getAddress(),
                        packet.getPort()));
                } catch (IOException e) {
                    // Expected when server closes
                }
            });

            UdpA2sClient client = new UdpA2sClient();
            Optional<A2sInfoResult> result = client.queryInfo("127.0.0.1", port);

            assertThat(result).isEmpty();
            executor.shutdown();
            executor.awaitTermination(1, TimeUnit.SECONDS);
        }
    }
}
