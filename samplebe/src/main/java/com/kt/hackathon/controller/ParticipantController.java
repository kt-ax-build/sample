package com.kt.hackathon.controller;

import com.kt.hackathon.dto.ParticipantDto;
import com.kt.hackathon.service.ParticipantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/participants")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:3000")
public class ParticipantController {
    
    private final ParticipantService participantService;
    
    @PostMapping
    public ResponseEntity<ParticipantDto> registerParticipant(@Valid @RequestBody ParticipantDto participantDto) {
        try {
            ParticipantDto registered = participantService.registerParticipant(participantDto);
            return ResponseEntity.ok(registered);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping
    public ResponseEntity<List<ParticipantDto>> getAllParticipants() {
        List<ParticipantDto> participants = participantService.getAllParticipants();
        return ResponseEntity.ok(participants);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ParticipantDto> getParticipantById(@PathVariable Long id) {
        try {
            ParticipantDto participant = participantService.getParticipantById(id);
            return ResponseEntity.ok(participant);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<List<ParticipantDto>> getParticipantsByStatus(@PathVariable String status) {
        List<ParticipantDto> participants = participantService.getParticipantsByStatus(status);
        return ResponseEntity.ok(participants);
    }
    
    @PutMapping("/{id}/status")
    public ResponseEntity<ParticipantDto> updateParticipantStatus(
            @PathVariable Long id, 
            @RequestParam String status) {
        try {
            ParticipantDto updated = participantService.updateParticipantStatus(id, status);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteParticipant(@PathVariable Long id) {
        try {
            participantService.deleteParticipant(id);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
} 