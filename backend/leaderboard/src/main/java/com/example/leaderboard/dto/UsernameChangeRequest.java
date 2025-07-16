package com.example.leaderboard.dto;


import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UsernameChangeRequest {
    private String oldUsername;
    private String newUsername;


}
