package com.kt.hackathon.repository;

import com.kt.hackathon.entity.Participant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ParticipantRepository extends JpaRepository<Participant, Long> {
    
    Optional<Participant> findByEmail(String email);
    
    List<Participant> findByStatus(String status);
    
    List<Participant> findByTeamName(String teamName);
    
    boolean existsByEmail(String email);
    
    boolean existsByTeamName(String teamName);
} 