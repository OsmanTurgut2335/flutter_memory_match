package com.example.leaderboard.controller;


import com.example.leaderboard.config.ApiProperties;
import com.example.leaderboard.dto.*;
import com.example.leaderboard.model.LeaderboardEntry;
import com.example.leaderboard.service.JwtService;
import com.example.leaderboard.service.LeaderboardService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/leaderboard")
public class LeaderboardController {

    private final LeaderboardService leaderboardService;
    private final ApiProperties apiProperties;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtService jwtService;


    public LeaderboardController(LeaderboardService leaderboardService, ApiProperties apiProperties,
                                 BCryptPasswordEncoder passwordEncoder,JwtService jwtService) {
        this.leaderboardService = leaderboardService;
        this.apiProperties = apiProperties;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    private boolean apiKeyIsValid(String providedKey) {
        return providedKey != null && providedKey.equals(apiProperties.getKey());
    }

    @PostMapping("/entry")
    public ResponseEntity<?> saveEntry(
            @RequestBody LeaderboardEntryRequest request,
            @RequestHeader(value = "x-api-key", required = false) String apiKey
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
        }

        String hashedPassword = passwordEncoder.encode(request.getPassword());

        LeaderboardEntry entry = new LeaderboardEntry(request.getUsername(), hashedPassword);
        LeaderboardEntry saved = leaderboardService.saveEntry(entry);

        return ResponseEntity.ok(saved);
    }

    @GetMapping("/top")
    public List<LeaderboardEntryDto> getUserScoresDesc() {
        return leaderboardService.findUsersDesc().stream()
                .map(LeaderboardEntryDto::new)
                .toList();
    }

    @GetMapping("/{username}")
    public ResponseEntity<?> findByUsername(@PathVariable String username) {
        return leaderboardService.findByUsername(username)
                .map(entry -> ResponseEntity.ok(new LeaderboardEntryDto(entry)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{username}")
    public ResponseEntity<?> deleteByUsername(
            @PathVariable String username,
            @RequestHeader(value = "x-api-key", required = false) String apiKey,
            @RequestHeader("Authorization") String authHeader
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
        }

        String token = authHeader.replace("Bearer ", "");
        String usernameFromToken = jwtService.extractUsername(token);

        if (!usernameFromToken.equals(username)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You can only delete your own account");
        }

        boolean deleted = leaderboardService.deleteByUsername(username);
        if (deleted) {
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }


    @PutMapping("/besttime")
    public ResponseEntity<String> updateBestTimeIfBetter(
            @RequestBody BestTimeUpdateRequest request,
            @RequestHeader(value = "x-api-key", required = false) String apiKey,
            @RequestHeader("Authorization") String authHeader
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
        }

        String token = authHeader.replace("Bearer ", "");
        String usernameFromToken = jwtService.extractUsername(token);

        if (!usernameFromToken.equals(request.getUsername())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You can only update your own best time");
        }

        boolean updated = leaderboardService.updateBestTimeIfBetter(request.getUsername(), request.getBestTime());
        if (updated) {
            return ResponseEntity.ok("Best time updated");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).body("No update needed");
        }
    }

    @PutMapping("/username")
    public ResponseEntity<?> updateUsername(
            @RequestBody UsernameChangeRequest request,
            @RequestHeader(value = "x-api-key", required = false) String apiKey,
            @RequestHeader("Authorization") String authHeader
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
        }

        String token = authHeader.replace("Bearer ", "");
        String usernameFromToken = jwtService.extractUsername(token);

        if (!usernameFromToken.equals(request.getOldUsername())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You can only change your own username");
        }

        try {
            LeaderboardEntry updated = leaderboardService.updateUsername(request.getOldUsername(), request.getNewUsername());
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }




    @GetMapping("/position/{username}")
    public ResponseEntity<LeaderboardEntryWithRank> getUserWithRank(@PathVariable String username) {
        return ResponseEntity.ok(leaderboardService.getUserWithRank(username));
    }


}
