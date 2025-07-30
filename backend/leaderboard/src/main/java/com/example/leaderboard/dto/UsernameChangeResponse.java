package com.example.leaderboard.dto;

import lombok.Getter;
import lombok.Setter;


@Setter
@Getter
public class UsernameChangeResponse {
    private String newUsername;
    private String accessToken;
    private String refreshToken;

    public UsernameChangeResponse(String newUsername, String accessToken,String refreshToken) {
        this.newUsername = newUsername;
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
    }

}
