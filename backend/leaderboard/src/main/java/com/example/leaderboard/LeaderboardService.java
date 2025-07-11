package com.example.leaderboard;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LeaderboardService {

    private final LeaderboardRepository leaderboardRepository;

    public LeaderboardService(LeaderboardRepository leaderboardRepository) {
        this.leaderboardRepository = leaderboardRepository;
    }

    public LeaderboardEntry findByUsername(String username) {
        return leaderboardRepository.findByUsername(username);
    }

    public void deleteByUsername(String username) {
        leaderboardRepository.deleteByUsername(username);
    }

    public List<LeaderboardEntry> findUsersDesc() {
        return leaderboardRepository.findAllByOrderByBestTimeDesc();
    }

    public LeaderboardEntry saveEntry(LeaderboardEntry entry) {
        return leaderboardRepository.save(entry);
    }

}
