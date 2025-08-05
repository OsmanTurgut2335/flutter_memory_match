package com.example.leaderboard.service;

import com.example.leaderboard.repository.HealthRepository;
import org.springframework.stereotype.Service;

@Service
public class HealthService {

    private final HealthRepository healthRepository;

    public HealthService(HealthRepository healthRepository) {
        this.healthRepository = healthRepository;
    }

    public boolean isDatabaseHealthy() {
        return healthRepository.isDatabaseUp();
    }
}
