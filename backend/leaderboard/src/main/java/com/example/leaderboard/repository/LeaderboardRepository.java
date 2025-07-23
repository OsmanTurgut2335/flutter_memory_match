package com.example.leaderboard.repository;

import com.example.leaderboard.model.LeaderboardEntry;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LeaderboardRepository extends JpaRepository<LeaderboardEntry, Long> {

    Optional<LeaderboardEntry> findByUsername(String username);



    List<LeaderboardEntry> findTop10ByOrderByScoreDesc();


    Optional<List<LeaderboardEntry>> findTop5ByOrderByMaxLevelDesc();

}
