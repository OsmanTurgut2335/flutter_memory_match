package com.example.leaderboard.controller;


import com.example.leaderboard.dto.BestTimeUpdateRequest;
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


    public LeaderboardController(LeaderboardService leaderboardService) {
        this.leaderboardService = leaderboardService;
    }


    @PostMapping("/entry")
    public LeaderboardEntry saveEntry(@RequestBody LeaderboardEntry entry){
      return   leaderboardService.saveEntry(entry);
    }

    @GetMapping("/sorted")
    public List<LeaderboardEntry> getUserScoresDesc(){
        return leaderboardService.findUsersDesc();
    }

    @DeleteMapping("/{username}")
    public ResponseEntity<Void> deleteByUsername(@PathVariable String username) {
        boolean deleted = leaderboardService.deleteByUsername(username);
        if (deleted) {
            return ResponseEntity.ok().build(); // 200 OK
        } else {
            return ResponseEntity.notFound().build(); // 404 Not Found
        }
    }
    @PutMapping("/besttime")
    public ResponseEntity<String> updateBestTimeIfBetter(@RequestBody BestTimeUpdateRequest request) {
        boolean updated = leaderboardService.updateBestTimeIfBetter(request.getUsername(), request.getBestTime());
        if (updated) {
            return ResponseEntity.ok("Best time updated");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_MODIFIED).body("No update needed");
        }
    }


    @PutMapping("/username")
    public ResponseEntity<LeaderboardEntry> updateUsername(@RequestBody UsernameChangeRequest request) {
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

}
