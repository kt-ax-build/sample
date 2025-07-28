package com.kt.hackathon.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "participants")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Participant {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(nullable = false)
    private String phone;
    
    @Column(nullable = false)
    private String organization;
    
    @Column(nullable = false)
    private String position;
    
    @Column(nullable = false)
    private String teamName;
    
    @Column(nullable = false)
    private String projectTitle;
    
    @Column(columnDefinition = "TEXT")
    private String projectDescription;
    
    @Column(nullable = false)
    private LocalDateTime registrationDate;
    
    @Column(nullable = false)
    private String status = "PENDING"; // PENDING, APPROVED, REJECTED
    
    @PrePersist
    protected void onCreate() {
        registrationDate = LocalDateTime.now();
    }
} 