package com.example.leaderboard.controller;

import com.example.leaderboard.dto.*;
import com.example.leaderboard.exception.DatabaseConnectionException;
import com.example.leaderboard.exception.NotFoundException;
import com.example.leaderboard.model.LeaderboardEntry;
import com.example.leaderboard.service.JwtService;
import com.example.leaderboard.service.LeaderboardService;
import com.example.leaderboard.util.SecurityUtil;

import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/leaderboard")
public class LeaderboardController {

    private final LeaderboardService leaderboardService;
    private final JwtService jwtService;
    private final SecurityUtil securityUtil;

    public LeaderboardController(
            LeaderboardService leaderboardService,
            JwtService jwtService,
            SecurityUtil securityUtil
    ) {
        this.leaderboardService = leaderboardService;
        this.jwtService = jwtService;
        this.securityUtil = securityUtil;
    }

    @GetMapping("/top")
    public List<LeaderboardEntryDto> getUserScoresDesc(
            @RequestHeader("x-api-key") String apiKey
    ) {
        securityUtil.checkApiKey(apiKey);

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
        securityUtil.checkApiKey(apiKey);
        securityUtil.checkUsernameMatch(authHeader, username);

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
        securityUtil.checkApiKey(apiKey);
        securityUtil.checkUsernameMatch(authHeader, request.getUsername());

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
        securityUtil.checkApiKey(apiKey);
        securityUtil.checkUsernameMatch(authHeader, request.getUsername());

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
        securityUtil.checkApiKey(apiKey);
        securityUtil.checkUsernameMatch(authHeader, request.getOldUsername());

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
        securityUtil.checkApiKey(apiKey);
        return ResponseEntity.ok(leaderboardService.getUserWithRank(username));
    }
}
