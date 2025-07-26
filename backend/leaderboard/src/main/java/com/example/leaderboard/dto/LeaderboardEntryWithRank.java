package com.example.leaderboard.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LeaderboardEntryWithRank {
    private String username;
    private int score;
    private int maxLevel;
    private int rank;
    private int bestTime;
    public LeaderboardEntryWithRank(String username, int score, int maxLevel, int rank, int bestTime) {
        this.username = username;
        this.score = score;
        this.maxLevel = maxLevel;
        this.rank = rank;
        this.bestTime = bestTime;
    }
    // constructor, getter, setter
}
