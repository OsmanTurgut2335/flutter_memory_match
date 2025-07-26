package com.example.leaderboard.controller;


import com.example.leaderboard.config.ApiProperties;
import com.example.leaderboard.dto.BestTimeUpdateRequest;
import com.example.leaderboard.dto.LeaderboardEntryWithRank;
import com.example.leaderboard.dto.UsernameChangeRequest;
import com.example.leaderboard.model.LeaderboardEntry;
import com.example.leaderboard.service.LeaderboardService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/leaderboard")
public class LeaderboardController {

    private final LeaderboardService leaderboardService;
    private final ApiProperties apiProperties;

    public LeaderboardController(LeaderboardService leaderboardService, ApiProperties apiProperties) {
        this.leaderboardService = leaderboardService;
        this.apiProperties = apiProperties;
    }

    private boolean apiKeyIsValid(String providedKey) {
        return providedKey != null && providedKey.equals(apiProperties.getKey());
    }

    @PostMapping("/entry")
    public ResponseEntity<?> saveEntry(
            @RequestBody LeaderboardEntry entry,
            @RequestHeader(value = "x-api-key", required = false) String apiKey
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
        }

        LeaderboardEntry saved = leaderboardService.saveEntry(entry);
        return ResponseEntity.ok(saved);
    }


    @GetMapping("/top")
    public List<LeaderboardEntry> getUserScoresDesc(){
        return leaderboardService.findUsersDesc();
    }

    @DeleteMapping("/{username}")
    public ResponseEntity<?> deleteByUsername(
            @PathVariable String username,
            @RequestHeader(value = "x-api-key", required = false) String apiKey
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
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
            @RequestHeader(value = "x-api-key", required = false) String apiKey
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
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
            @RequestHeader(value = "x-api-key", required = false) String apiKey
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
        }

        try {
            LeaderboardEntry updated = leaderboardService.updateUsername(request.getOldUsername(), request.getNewUsername());
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }


    @GetMapping("/{username}")
    public Optional<LeaderboardEntry> findByUsername(@PathVariable String username){
        return leaderboardService.findByUsername(username);
    }

    @GetMapping("/position/{username}")
    public ResponseEntity<LeaderboardEntryWithRank> getUserWithRank(@PathVariable String username) {
        return ResponseEntity.ok(leaderboardService.getUserWithRank(username));
    }


}
