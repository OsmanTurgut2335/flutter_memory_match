package com.example.leaderboard;


import org.springframework.web.bind.annotation.*;

import java.util.List;

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
    public void deleteByUsername(@PathVariable String username){
        leaderboardService.deleteByUsername(username);
    }

    @GetMapping("/{username}")
    public LeaderboardEntry findByUsername(@PathVariable String username){
        return leaderboardService.findByUsername(username);
    }

}
