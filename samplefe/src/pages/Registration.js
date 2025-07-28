import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  TextField,
  Button,
  Card,
  CardContent,
  Grid,
  Alert,
  Snackbar,
  Paper,
  Stepper,
  Step,
  StepLabel,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions
} from '@mui/material';
import axios from 'axios';

const steps = ['기본 정보', '팀 정보', '프로젝트 정보'];

const Registration = () => {
  const navigate = useNavigate();
  const [activeStep, setActiveStep] = useState(0);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    organization: '',
    position: '',
    teamName: '',
    projectTitle: '',
    projectDescription: ''
  });
  const [errors, setErrors] = useState({});
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: '',
    severity: 'success'
  });
  const [successModal, setSuccessModal] = useState({
    open: false,
    message: ''
  });

  const handleInputChange = (field) => (event) => {
    const value = event.target.value;
    setFormData({
      ...formData,
      [field]: value
    });
    
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors({
        ...errors,
        [field]: ''
      });
    }
    
    // 실시간 검증 (전화번호와 프로젝트 설명)
    if (field === 'phone' && value.trim()) {
      if (value.length < 10 || value.length > 15) {
        setErrors({
          ...errors,
          [field]: '전화번호는 10자 이상 15자 이하여야 합니다'
        });
      }
    }
    
    if (field === 'projectDescription' && value.trim()) {
      if (value.length < 10) {
        setErrors({
          ...errors,
          [field]: '프로젝트 설명은 10자 이상 입력해주세요'
        });
      } else if (value.length > 2000) {
        setErrors({
          ...errors,
          [field]: '프로젝트 설명은 2000자 이하여야 합니다'
        });
      }
    }
  };

  const validateStep = (step) => {
    const newErrors = {};
    
    switch (step) {
      case 0:
        if (!formData.name.trim()) newErrors.name = '이름을 입력해주세요';
        if (!formData.email.trim()) newErrors.email = '이메일을 입력해주세요';
        else if (!/\S+@\S+\.\S+/.test(formData.email)) newErrors.email = '유효한 이메일 형식이 아닙니다';
        if (!formData.phone.trim()) newErrors.phone = '전화번호를 입력해주세요';
        else if (formData.phone.length < 10 || formData.phone.length > 15) newErrors.phone = '전화번호는 10자 이상 15자 이하여야 합니다';
        if (!formData.organization.trim()) newErrors.organization = '소속을 입력해주세요';
        if (!formData.position.trim()) newErrors.position = '직책을 입력해주세요';
        break;
      case 1:
        if (!formData.teamName.trim()) newErrors.teamName = '팀명을 입력해주세요';
        break;
      case 2:
        if (!formData.projectTitle.trim()) newErrors.projectTitle = '프로젝트 제목을 입력해주세요';
        if (!formData.projectDescription.trim()) newErrors.projectDescription = '프로젝트 설명을 입력해주세요';
        else if (formData.projectDescription.length < 10) newErrors.projectDescription = '프로젝트 설명은 10자 이상 입력해주세요';
        else if (formData.projectDescription.length > 2000) newErrors.projectDescription = '프로젝트 설명은 2000자 이하여야 합니다';
        break;
      default:
        break;
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    if (validateStep(activeStep)) {
      setActiveStep((prevStep) => prevStep + 1);
    }
  };

  const handleBack = () => {
    setActiveStep((prevStep) => prevStep - 1);
  };

  const handleSubmit = async () => {
    if (!validateStep(activeStep)) return;

    try {
      await axios.post('/api/participants', formData);
      // 성공 모달 표시
      setSuccessModal({
        open: true,
        message: '참가 신청이 성공적으로 완료되었습니다!'
      });
    } catch (error) {
      setSnackbar({
        open: true,
        message: error.response?.data?.message || '참가 신청 중 오류가 발생했습니다.',
        severity: 'error'
      });
    }
  };

  const handleSuccessModalClose = () => {
    setSuccessModal({ open: false, message: '' });
    // 폼 초기화
    setFormData({
      name: '',
      email: '',
      phone: '',
      organization: '',
      position: '',
      teamName: '',
      projectTitle: '',
      projectDescription: ''
    });
    setActiveStep(0);
    // 홈화면으로 이동
    navigate('/');
  };

  const handleCloseSnackbar = () => {
    setSnackbar({ ...snackbar, open: false });
  };

  const renderStepContent = (step) => {
    switch (step) {
      case 0:
        return (
          <Grid container spacing={3}>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="이름 *"
                value={formData.name}
                onChange={handleInputChange('name')}
                error={!!errors.name}
                helperText={errors.name}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="이메일 *"
                type="email"
                value={formData.email}
                onChange={handleInputChange('email')}
                error={!!errors.email}
                helperText={errors.email}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="전화번호 *"
                value={formData.phone}
                onChange={handleInputChange('phone')}
                error={!!errors.phone}
                helperText={
                  errors.phone || 
                  `${formData.phone.length}/15자 (10-15자 입력)`
                }
                inputProps={{
                  maxLength: 15
                }}
                placeholder="01012345678"
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="소속 *"
                value={formData.organization}
                onChange={handleInputChange('organization')}
                error={!!errors.organization}
                helperText={errors.organization}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="직책 *"
                value={formData.position}
                onChange={handleInputChange('position')}
                error={!!errors.position}
                helperText={errors.position}
              />
            </Grid>
          </Grid>
        );
      case 1:
        return (
          <Grid container spacing={3}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="팀명 *"
                value={formData.teamName}
                onChange={handleInputChange('teamName')}
                error={!!errors.teamName}
                helperText={errors.teamName}
              />
            </Grid>
          </Grid>
        );
      case 2:
        return (
          <Grid container spacing={3}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="프로젝트 제목 *"
                value={formData.projectTitle}
                onChange={handleInputChange('projectTitle')}
                error={!!errors.projectTitle}
                helperText={errors.projectTitle}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="프로젝트 설명 *"
                multiline
                rows={6}
                value={formData.projectDescription}
                onChange={handleInputChange('projectDescription')}
                error={!!errors.projectDescription}
                helperText={
                  errors.projectDescription || 
                  `${formData.projectDescription.length}/2000자 (최소 10자 이상)`
                }
                inputProps={{
                  maxLength: 2000
                }}
              />
            </Grid>
          </Grid>
        );
      default:
        return null;
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ textAlign: 'center', mb: 4 }}>
        참가 신청
      </Typography>
      
      <Paper sx={{ p: 4, maxWidth: 800, mx: 'auto' }}>
        <Stepper activeStep={activeStep} sx={{ mb: 4 }}>
          {steps.map((label) => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
            </Step>
          ))}
        </Stepper>

        <Card>
          <CardContent>
            {renderStepContent(activeStep)}
            
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 4 }}>
              <Button
                disabled={activeStep === 0}
                onClick={handleBack}
              >
                이전
              </Button>
              <Box>
                {activeStep === steps.length - 1 ? (
                  <Button
                    variant="contained"
                    onClick={handleSubmit}
                  >
                    신청 완료
                  </Button>
                ) : (
                  <Button
                    variant="contained"
                    onClick={handleNext}
                  >
                    다음
                  </Button>
                )}
              </Box>
            </Box>
          </CardContent>
        </Card>
      </Paper>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={handleCloseSnackbar}
      >
        <Alert
          onClose={handleCloseSnackbar}
          severity={snackbar.severity}
          sx={{ width: '100%' }}
        >
          {snackbar.message}
        </Alert>
      </Snackbar>

      {/* 성공 모달 */}
      <Dialog
        open={successModal.open}
        onClose={handleSuccessModalClose}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle sx={{ textAlign: 'center', color: 'success.main' }}>
          🎉 참가 신청 완료
        </DialogTitle>
        <DialogContent>
          <Typography variant="body1" sx={{ textAlign: 'center', py: 2 }}>
            {successModal.message}
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ textAlign: 'center' }}>
            확인 버튼을 누르시면 홈화면으로 이동합니다.
          </Typography>
        </DialogContent>
        <DialogActions sx={{ justifyContent: 'center', pb: 3 }}>
          <Button
            variant="contained"
            onClick={handleSuccessModalClose}
            sx={{ minWidth: 120 }}
          >
            확인
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Registration; 