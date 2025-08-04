package com.example.leaderboard.service;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.Date;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secretKey;

    private final long ACCESS_TOKEN_EXPIRY = 15 * 60 * 1000; // 15 dk
    private final long REFRESH_TOKEN_EXPIRY = 7 * 24 * 60 * 60 * 1000; // 7 gün

    public String generateAccessToken(String username) {
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_TOKEN_EXPIRY))
                .signWith(Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8)), SignatureAlgorithm.HS256)
                .compact();
    }

    public String generateRefreshToken(String username) {
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + REFRESH_TOKEN_EXPIRY))
                .signWith(Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8)), SignatureAlgorithm.HS256)
                .compact();
    }
    public String extractUsername(String token) {
        System.out.println("[JWT] Extracting username from token: " + token);
        try {
            String username = Jwts.parserBuilder()
                    .setAllowedClockSkewSeconds(30)
                    .setSigningKey(secretKey.getBytes(StandardCharsets.UTF_8))
                    .build()
                    .parseClaimsJws(token)
                    .getBody()
                    .getSubject();
            System.out.println("[JWT] Username extracted: " + username);
            return username;
        } catch (Exception e) {
            System.out.println("[JWT] Failed to extract username: " + e.getMessage());
            throw e;
        }
    }



    public String extractUsernameAllowExpired(String token) {
        try {
            return extractUsername(token);
        } catch (ExpiredJwtException e) {
            System.out.println("[JWT] Token expired, extracting from claims: " + e.getClaims().getSubject());
            return e.getClaims().getSubject();
        }
    }


    public boolean validateToken(String token, String username) {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(secretKey.getBytes(StandardCharsets.UTF_8))
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            boolean subjectMatch = claims.getSubject().equals(username);
            boolean notExpired = claims.getExpiration().after(new Date());

            System.out.println("[JWT] Validating token for username: " + username);
            System.out.println("[JWT] Subject matches: " + subjectMatch);
            System.out.println("[JWT] Not expired: " + notExpired);

            return subjectMatch && notExpired;
        } catch (JwtException e) {
            System.out.println("[JWT] Token validation failed: " + e.getMessage());
            return false;
        }
    }

}
