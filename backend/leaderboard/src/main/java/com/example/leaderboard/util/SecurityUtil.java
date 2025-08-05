package com.example.leaderboard.util;

import com.example.leaderboard.config.ApiProperties;
import com.example.leaderboard.exception.ForbiddenException;
import com.example.leaderboard.exception.UnauthorizedException;
import com.example.leaderboard.service.JwtService;
import org.springframework.stereotype.Component;

@Component
public class SecurityUtil {

    private final ApiProperties apiProperties;
    private final JwtService jwtService;

    public SecurityUtil(ApiProperties apiProperties, JwtService jwtService) {
        this.apiProperties = apiProperties;
        this.jwtService = jwtService;
    }

    public void checkApiKey(String apiKey) {
        if (apiKey == null || !apiKey.equals(apiProperties.getKey())) {
            throw new UnauthorizedException("Invalid API Key");
        }
    }

    public void checkUsernameMatch(String token, String expectedUsername) {
        String actual = jwtService.extractUsername(token.replace("Bearer ", ""));
        if (!actual.equals(expectedUsername)) {
            throw new ForbiddenException("You can only operate on your own user");
        }
    }
    public void validateToken(String token) {
        if (token == null || !jwtService.isTokenValid(token.replace("Bearer ", ""))) {
            throw new UnauthorizedException("Invalid or expired token");
        }
    }

}
