package com.jbforsaken.web.auth;

public record SteamProfile(long steamId64, String nickname, String avatarUrl) {
}
