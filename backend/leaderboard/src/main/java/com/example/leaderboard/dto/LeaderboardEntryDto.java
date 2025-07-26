package com.example.leaderboard.dto;

import com.example.leaderboard.model.LeaderboardEntry;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LeaderboardEntryDto {
    private String username;
    private int score;
    private int maxLevel;
    private int bestTime;

    public LeaderboardEntryDto(LeaderboardEntry entry) {
        this.username = entry.getUsername();
        this.score = entry.getScore();
        this.maxLevel = entry.getMaxLevel();
        this.bestTime = entry.getBestTime();
    }
}
