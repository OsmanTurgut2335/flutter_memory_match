package com.example.leaderboard.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BestTimeUpdateRequest {

    private String username;
    private int bestTime;
}
