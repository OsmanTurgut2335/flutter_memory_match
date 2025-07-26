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

    @Column(name = "maxLevel")
    private int maxLevel=0;

    @Column(name = "best_time")
    private int bestTime= -1;

    @Column(name = "score")
    private  int score = 0;






    public LeaderboardEntry( String username ) {

        this.username = username;


    }
}
