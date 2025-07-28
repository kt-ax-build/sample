package com.kt.hackathon.service;

import com.kt.hackathon.dto.ParticipantDto;
import com.kt.hackathon.entity.Participant;
import com.kt.hackathon.repository.ParticipantRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ParticipantService {
    
    private final ParticipantRepository participantRepository;
    private final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    public ParticipantDto registerParticipant(ParticipantDto participantDto) {
        // 이메일 중복 확인
        if (participantRepository.existsByEmail(participantDto.getEmail())) {
            throw new RuntimeException("이미 등록된 이메일입니다.");
        }
        
        // 팀명 중복 확인
        if (participantRepository.existsByTeamName(participantDto.getTeamName())) {
            throw new RuntimeException("이미 사용 중인 팀명입니다.");
        }
        
        Participant participant = new Participant();
        participant.setName(participantDto.getName());
        participant.setEmail(participantDto.getEmail());
        participant.setPhone(participantDto.getPhone());
        participant.setOrganization(participantDto.getOrganization());
        participant.setPosition(participantDto.getPosition());
        participant.setTeamName(participantDto.getTeamName());
        participant.setProjectTitle(participantDto.getProjectTitle());
        participant.setProjectDescription(participantDto.getProjectDescription());
        
        Participant savedParticipant = participantRepository.save(participant);
        return convertToDto(savedParticipant);
    }
    
    @Transactional(readOnly = true)
    public List<ParticipantDto> getAllParticipants() {
        return participantRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public ParticipantDto getParticipantById(Long id) {
        Participant participant = participantRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("참가자를 찾을 수 없습니다."));
        return convertToDto(participant);
    }
    
    @Transactional(readOnly = true)
    public List<ParticipantDto> getParticipantsByStatus(String status) {
        return participantRepository.findByStatus(status).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public ParticipantDto updateParticipantStatus(Long id, String status) {
        Participant participant = participantRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("참가자를 찾을 수 없습니다."));
        participant.setStatus(status);
        Participant updatedParticipant = participantRepository.save(participant);
        return convertToDto(updatedParticipant);
    }
    
    public void deleteParticipant(Long id) {
        if (!participantRepository.existsById(id)) {
            throw new RuntimeException("참가자를 찾을 수 없습니다.");
        }
        participantRepository.deleteById(id);
    }
    
    private ParticipantDto convertToDto(Participant participant) {
        ParticipantDto dto = new ParticipantDto();
        dto.setId(participant.getId());
        dto.setName(participant.getName());
        dto.setEmail(participant.getEmail());
        dto.setPhone(participant.getPhone());
        dto.setOrganization(participant.getOrganization());
        dto.setPosition(participant.getPosition());
        dto.setTeamName(participant.getTeamName());
        dto.setProjectTitle(participant.getProjectTitle());
        dto.setProjectDescription(participant.getProjectDescription());
        dto.setStatus(participant.getStatus());
        dto.setRegistrationDate(participant.getRegistrationDate().format(formatter));
        return dto;
    }
} 