package com.example.leaderboard.model;


//Model Class for leaderboard inputs

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class LeaderboardEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long  id;

    @Column(unique = true)
    private String username;

    @Column(name = "best_time")
    private int bestTime;


    public LeaderboardEntry( String username, int bestTime) {

        this.username = username;
        this.bestTime = bestTime;
    }
}
