package com.example.leaderboard.service;


import com.example.leaderboard.dto.LeaderboardEntryWithRank;
import com.example.leaderboard.model.LeaderboardEntry;
import com.example.leaderboard.repository.LeaderboardRepository;
import org.springframework.http.HttpStatus;

import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;

@Service
public class LeaderboardService {

    private final LeaderboardRepository leaderboardRepository;

    public LeaderboardService(LeaderboardRepository leaderboardRepository) {
        this.leaderboardRepository = leaderboardRepository;
    }

    public Optional<LeaderboardEntry> findByUsername(String username) {
        return leaderboardRepository.findByUsername(username);
    }


    public boolean deleteByUsername(String username) {
        Optional<LeaderboardEntry> entryOpt = leaderboardRepository.findByUsername(username);
        if (entryOpt.isPresent()) {
            leaderboardRepository.delete(entryOpt.get());

            return true;
        } else {
            return false;
        }
    }
    public LeaderboardEntry updateUsername(String oldUsername, String newUsername, String newRefreshToken) {
        if (newUsername == null || newUsername.trim().isEmpty()) {
            throw new IllegalArgumentException("New username cannot be blank");
        }

        if (!newUsername.matches("^[a-zA-Z0-9_]{3,20}$")) {
            throw new IllegalArgumentException("Username must be 3–20 chars, alphanumeric or underscore only");
        }

        Optional<LeaderboardEntry> existingOpt = leaderboardRepository.findByUsername(oldUsername);
        if (existingOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        if (leaderboardRepository.findByUsername(newUsername).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already taken");
        }

        LeaderboardEntry entry = existingOpt.get();
        entry.setUsername(newUsername);
        entry.setRefreshToken(newRefreshToken);  
        return leaderboardRepository.save(entry);
    }

    public void updateCoins(String username, int coins) {
        Optional<LeaderboardEntry> opt = leaderboardRepository.findByUsername(username);
        if (opt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        LeaderboardEntry entry = opt.get();
        entry.setCoins(coins);
        leaderboardRepository.save(entry);
    }


    public LeaderboardEntry saveUser(LeaderboardEntry entry) {
        return leaderboardRepository.save(entry);
    }

    public boolean updateBestTimeIfBetter(String username, int newTime, int newLevel, int newScore) {
        Optional<LeaderboardEntry> optional = leaderboardRepository.findByUsername(username);
        if (optional.isEmpty()) return false;

        LeaderboardEntry entry = optional.get();
        boolean updated = false;


        if (newLevel > entry.getMaxLevel()) {
            entry.setMaxLevel(newLevel);
            entry.setBestTime(newTime);
            updated = true;
        } else if (newLevel == entry.getMaxLevel() && newTime < entry.getBestTime()) {

            entry.setBestTime(newTime);
            updated = true;
        }


        if (newScore > entry.getScore()) {
            entry.setScore(newScore);
            updated = true;
        }

        if (updated) {
            leaderboardRepository.save(entry);
        }

        return updated;
    }




    public List<LeaderboardEntry> findUsersDesc() {
        return leaderboardRepository.findTop10ByOrderByScoreDesc();
    }

    public LeaderboardEntry saveEntry(LeaderboardEntry entry) {
        boolean usernameExists = leaderboardRepository.findByUsername(entry.getUsername()).isPresent();

        if (usernameExists) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Username already exists. Use update endpoint to change score."
            );
        }

        return leaderboardRepository.save(entry);
    }

    public LeaderboardEntryWithRank getUserWithRank(String username) {
        List<LeaderboardEntry> sorted = leaderboardRepository.findAllByOrderByScoreDesc();
        for (int i = 0; i < sorted.size(); i++) {
            if (sorted.get(i).getUsername().equals(username)) {
                LeaderboardEntry user = sorted.get(i);
                return new LeaderboardEntryWithRank(user.getUsername(), user.getScore(), user.getMaxLevel(), i + 1,user.getBestTime());
            }
        }
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found in leaderboard");

    }
    public void updateRefreshToken(LeaderboardEntry entry, String refreshToken) {
        entry.setRefreshToken(refreshToken);
        leaderboardRepository.save(entry);
    }



}
