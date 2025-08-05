package com.example.leaderboard.controller;

import com.example.leaderboard.config.ApiProperties;
import com.example.leaderboard.service.HealthService;
import com.example.leaderboard.service.JwtService;
import com.example.leaderboard.util.SecurityUtil;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/health")
public class HealthController {

    private final HealthService healthService;
    private final ApiProperties apiProperties;
    private final SecurityUtil securityUtil;

    public HealthController(
            HealthService healthService,
            ApiProperties apiProperties,
            SecurityUtil securityUtil
    ) {
        this.healthService = healthService;
        this.apiProperties = apiProperties;
        this.securityUtil = securityUtil;
    }

    @GetMapping("/db")
    public ResponseEntity<String> checkDatabaseHealth(
            @RequestHeader(value = "x-api-key", required = false) String apiKey,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {
        securityUtil.checkApiKey(apiKey);
        securityUtil.validateToken(authHeader);

        boolean healthy = healthService.isDatabaseHealthy();
        return healthy
                ? ResponseEntity.ok("Database is UP")
                : ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body("Database is DOWN");
    }

}
