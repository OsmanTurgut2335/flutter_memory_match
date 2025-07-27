package com.example.leaderboard.controller;

import com.example.leaderboard.config.ApiProperties;
import com.example.leaderboard.dto.LeaderboardEntryRequest;
import com.example.leaderboard.model.LeaderboardEntry;
import com.example.leaderboard.service.JwtService;
import com.example.leaderboard.service.LeaderboardService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final LeaderboardService leaderboardService;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final ApiProperties apiProperties;

    public AuthController(LeaderboardService leaderboardService, BCryptPasswordEncoder passwordEncoder, JwtService jwtService,
                          ApiProperties apiProperties) {
        this.leaderboardService = leaderboardService;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.apiProperties = apiProperties;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LeaderboardEntryRequest request) {
        LeaderboardEntry user = leaderboardService
                .findByUsername(request.getUsername())
                .orElse(null);

        if (user == null || !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        }

        String token = jwtService.generateToken(user.getUsername());
        return ResponseEntity.ok(Map.of("token", token, "username", user.getUsername()));
    }


    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestBody LeaderboardEntryRequest request,
            @RequestHeader(value = "x-api-key", required = false) String apiKey
    ) {
        if (!apiKeyIsValid(apiKey)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid API Key");
        }

        if (leaderboardService.findByUsername(request.getUsername()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Username already exists");
        }

        String hashedPassword = passwordEncoder.encode(request.getPassword());
        LeaderboardEntry entry = new LeaderboardEntry(request.getUsername(), hashedPassword);
        LeaderboardEntry saved = leaderboardService.saveEntry(entry);

        String token = jwtService.generateToken(saved.getUsername());

        return ResponseEntity.ok(Map.of(
                "token", token,
                "username", saved.getUsername()
        ));
    }
    private boolean apiKeyIsValid(String providedKey) {
        return providedKey != null && providedKey.equals(apiProperties.getKey());
    }

}
