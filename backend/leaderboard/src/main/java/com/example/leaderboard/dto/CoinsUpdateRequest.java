package com.example.leaderboard.dto;


import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class CoinsUpdateRequest {
    private String username;
    private int coins;


}
