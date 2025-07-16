package com.example.leaderboard.service;

import com.example.leaderboard.model.LeaderboardEntry;
import com.example.leaderboard.repository.LeaderboardRepository;
import org.springframework.stereotype.Service;

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
    public LeaderboardEntry updateUsername(String oldUsername, String newUsername) {
        Optional<LeaderboardEntry> existingOpt = leaderboardRepository.findByUsername(oldUsername);

        if (existingOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        LeaderboardEntry entry = existingOpt.get();

        entry.setUsername(newUsername);
        return leaderboardRepository.save(entry);
    }

    public boolean updateBestTimeIfBetter(String username, int newBestTime) {
        Optional<LeaderboardEntry> optionalEntry = leaderboardRepository.findByUsername(username);
        if (optionalEntry.isPresent()) {
            LeaderboardEntry entry = optionalEntry.get();
            if (entry.getBestTime() == 0 || newBestTime < entry.getBestTime()) {
                entry.setBestTime(newBestTime);
                leaderboardRepository.save(entry);
                return true;
            }
        }
        return false;
    }




    public List<LeaderboardEntry> findUsersDesc() {
        return leaderboardRepository.findAllByOrderByBestTimeDesc();
    }

    public LeaderboardEntry saveEntry(LeaderboardEntry entry) {
        Optional<LeaderboardEntry> existingOpt = leaderboardRepository.findByUsername(entry.getUsername());

        if (existingOpt.isPresent()) {
            LeaderboardEntry existing = existingOpt.get();

            // Daha iyi (daha düşük) skor geldiyse güncelle
            if (entry.getBestTime() < existing.getBestTime()) {
                existing.setBestTime(entry.getBestTime());
                return leaderboardRepository.save(existing);
            }

            // Daha kötü skorla geleni yok say, mevcut veriyi döndür
            return existing;
        }

        // Yeni kullanıcı ise direkt kaydet
        return leaderboardRepository.save(entry);
    }


}
