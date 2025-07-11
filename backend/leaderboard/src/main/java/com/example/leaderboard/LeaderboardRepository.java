package com.example.leaderboard;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LeaderboardRepository extends JpaRepository<LeaderboardEntry, Long> {

    LeaderboardEntry findByUsername(String username);

    void deleteByUsername(String username);

    List<LeaderboardEntry> findAllByOrderByBestTimeDesc();

}
