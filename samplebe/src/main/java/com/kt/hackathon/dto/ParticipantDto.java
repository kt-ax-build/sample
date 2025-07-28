package com.kt.hackathon.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ParticipantDto {
    
    private Long id;
    
    @NotBlank(message = "이름은 필수입니다")
    @Size(min = 2, max = 50, message = "이름은 2자 이상 50자 이하여야 합니다")
    private String name;
    
    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "유효한 이메일 형식이 아닙니다")
    private String email;
    
    @NotBlank(message = "전화번호는 필수입니다")
    @Size(min = 10, max = 15, message = "전화번호는 10자 이상 15자 이하여야 합니다")
    private String phone;
    
    @NotBlank(message = "소속은 필수입니다")
    private String organization;
    
    @NotBlank(message = "직책은 필수입니다")
    private String position;
    
    @NotBlank(message = "팀명은 필수입니다")
    @Size(min = 2, max = 100, message = "팀명은 2자 이상 100자 이하여야 합니다")
    private String teamName;
    
    @NotBlank(message = "프로젝트 제목은 필수입니다")
    @Size(min = 5, max = 200, message = "프로젝트 제목은 5자 이상 200자 이하여야 합니다")
    private String projectTitle;
    
    @NotBlank(message = "프로젝트 설명은 필수입니다")
    @Size(min = 10, max = 2000, message = "프로젝트 설명은 10자 이상 2000자 이하여야 합니다")
    private String projectDescription;
    
    private String status;
    
    private String registrationDate;
} 