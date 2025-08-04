package com.example.leaderboard.controller;

import com.example.leaderboard.config.ApiProperties;
import com.example.leaderboard.dto.*;
import com.example.leaderboard.exception.DatabaseConnectionException;
import com.example.leaderboard.exception.ForbiddenException;
import com.example.leaderboard.exception.NotFoundException;
import com.example.leaderboard.exception.UnauthorizedException;
import com.example.leaderboard.model.LeaderboardEntry;
import com.example.leaderboard.service.JwtService;
import com.example.leaderboard.service.LeaderboardService;
import jakarta.validation.Valid;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/leaderboard")
public class LeaderboardController {

    private final LeaderboardService leaderboardService;
    private final ApiProperties apiProperties;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public LeaderboardController(
            LeaderboardService leaderboardService,
            ApiProperties apiProperties,
            BCryptPasswordEncoder passwordEncoder,
            JwtService jwtService
    ) {
        this.leaderboardService = leaderboardService;
        this.apiProperties = apiProperties;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    private void checkApiKey(String apiKey) {
        if (apiKey == null || !apiKey.equals(apiProperties.getKey())) {
            throw new UnauthorizedException("Invalid API Key");
        }
    }

    private void checkUsernameMatch(String token, String expectedUsername) {
        String actual = jwtService.extractUsername(token.replace("Bearer ", ""));

        System.out.println("Expected: " + expectedUsername);
        System.out.println("Actual (from token): " + actual);

        if (!actual.equals(expectedUsername)) {

            throw new ForbiddenException("You can only operate on your own user");
        }
    }



    @GetMapping("/top")
    public List<LeaderboardEntryDto> getUserScoresDesc(
            @RequestHeader("x-api-key") String apiKey
    ) {
        checkApiKey(apiKey);

        try {

            List<LeaderboardEntryDto> result = leaderboardService.findUsersDesc()
                    .stream()
                    .map(LeaderboardEntryDto::new)
                    .toList();

            if (result.isEmpty()) {
                throw new NotFoundException("No leaderboard entries found.");
            }

            return result;
        } catch (DataAccessException ex) {
            throw new DatabaseConnectionException("Database connection failed while fetching leaderboard.");
        } catch (Exception ex) {
            throw new RuntimeException("Unexpected error while fetching leaderboard", ex);
        }
    }


    @GetMapping("/{username}")
    public ResponseEntity<LeaderboardEntryDto> findByUsername(@PathVariable String username) {
        LeaderboardEntry entry = leaderboardService.findByUsername(username)
                .orElseThrow(() -> new NotFoundException("User not found"));
        return ResponseEntity.ok(new LeaderboardEntryDto(entry));
    }

    @DeleteMapping("/{username}")
    public ResponseEntity<?> deleteByUsername(
            @PathVariable String username,
            @RequestHeader(value = "x-api-key", required = false) String apiKey,
            @RequestHeader("Authorization") String authHeader
    ) {
        checkApiKey(apiKey);
        checkUsernameMatch(authHeader, username);

        boolean deleted = leaderboardService.deleteByUsername(username);
        if (!deleted) throw new NotFoundException("User not found");

        return ResponseEntity.ok().build();
    }

    @PutMapping("/bestTime")
    public ResponseEntity<String> updateBestTimeIfBetter(
            @RequestBody BestTimeUpdateRequest request,
            @RequestHeader(value = "x-api-key", required = false) String apiKey,
            @RequestHeader("Authorization") String authHeader
    ) {

        checkApiKey(apiKey);
        checkUsernameMatch(authHeader, request.getUsername());

        boolean updated = leaderboardService.updateBestTimeIfBetter(request.getUsername(), request.getBestTime(),request.getLevel(), request.getScore());

        return updated
                ? ResponseEntity.ok("Data updated")
                : ResponseEntity.status(HttpStatus.NOT_MODIFIED).body("No update needed");

    }

    @PutMapping("/coins")
    public ResponseEntity<?> updateCoins(
            @RequestBody CoinsUpdateRequest request,
            @RequestHeader("Authorization") String authHeader,
            @RequestHeader(value = "x-api-key", required = false) String apiKey
    ) {
        checkApiKey(apiKey);
        checkUsernameMatch(authHeader, request.getUsername());

        try {
            leaderboardService.updateCoins(request.getUsername(), request.getCoins());
            return ResponseEntity.ok("Coins updated");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }
    }

    @PutMapping("/username")
    public ResponseEntity<UsernameChangeResponse> updateUsername(
            @RequestBody UsernameChangeRequest request,
            @RequestHeader(value = "x-api-key", required = false) String apiKey,
            @RequestHeader("Authorization") String authHeader
    ) {
        checkApiKey(apiKey);
        checkUsernameMatch(authHeader, request.getOldUsername());


        String newAccessToken = jwtService.generateAccessToken(request.getNewUsername());
        String newRefreshToken = jwtService.generateRefreshToken(request.getNewUsername());


        LeaderboardEntry updated = leaderboardService.updateUsername(
                request.getOldUsername(),
                request.getNewUsername(),
                newRefreshToken
        );

        return ResponseEntity.ok(new UsernameChangeResponse(
                updated.getUsername(),
                newAccessToken,
                newRefreshToken
        ));
    }



    @GetMapping("/position/{username}")
    public ResponseEntity<LeaderboardEntryWithRank> getUserWithRank(
            @PathVariable String username,
            @RequestHeader("x-api-key") String apiKey
    ) {
        checkApiKey(apiKey);
        return ResponseEntity.ok(leaderboardService.getUserWithRank(username));
    }

}
