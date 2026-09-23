package com.jbforsaken.web.user;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import org.junit.jupiter.api.Test;

class WebUserTests {

    @Test
    void recordLogin_withNullNicknameAndAvatar_keepsPreviouslyStoredValues() {
        Instant firstLogin = Instant.parse("2026-09-22T10:00:00Z");
        WebUser user = new WebUser(1L, "OldName", "https://old-avatar", firstLogin);

        Instant laterLogin = Instant.parse("2026-09-22T11:00:00Z");
        user.recordLogin(null, null, laterLogin);

        assertThat(user.getNickname()).isEqualTo("OldName");
        assertThat(user.getAvatarUrl()).isEqualTo("https://old-avatar");
        assertThat(user.getLastLoginAt()).isEqualTo(laterLogin);
    }

    @Test
    void recordLogin_withNonNullValues_overwritesPreviouslyStoredValues() {
        Instant firstLogin = Instant.parse("2026-09-22T10:00:00Z");
        WebUser user = new WebUser(1L, "OldName", "https://old-avatar", firstLogin);

        Instant laterLogin = Instant.parse("2026-09-22T11:00:00Z");
        user.recordLogin("NewName", "https://new-avatar", laterLogin);

        assertThat(user.getNickname()).isEqualTo("NewName");
        assertThat(user.getAvatarUrl()).isEqualTo("https://new-avatar");
        assertThat(user.getLastLoginAt()).isEqualTo(laterLogin);
    }
}
