import React from 'react';
import {
  Box,
  Typography,
  Button,
  Card,
  CardContent,
  Grid,
  Container,
  Paper
} from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';
import EventIcon from '@mui/icons-material/Event';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import GroupIcon from '@mui/icons-material/Group';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';

const Home = () => {
  const highlights = [
    {
      icon: <EventIcon sx={{ fontSize: 40 }} />,
      title: '3일간의 집중 개발',
      description: '2025년 9월 1일부터 3일간 원수 수련원에서 진행'
    },
    {
      icon: <GroupIcon sx={{ fontSize: 40 }} />,
      title: '팀 빌딩 및 협업',
      description: '다양한 분야의 개발자들과 함께하는 협업 기회'
    },
    {
      icon: <EmojiEventsIcon sx={{ fontSize: 40 }} />,
      title: '우수 팀 시상',
      description: '혁신적인 프로젝트에 대한 상장 및 상품 제공'
    }
  ];

  return (
    <Box>
      {/* Hero Section */}
      <Paper
        sx={{
          position: 'relative',
          backgroundColor: 'grey.800',
          color: 'white',
          mb: 4,
          backgroundSize: 'cover',
          backgroundRepeat: 'no-repeat',
          backgroundPosition: 'center',
          backgroundImage: 'linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)), url(https://images.unsplash.com/photo-1518709268805-4e9042af2176?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1925&q=80)',
          height: '400px',
          display: 'flex',
          alignItems: 'center'
        }}
      >
        <Container maxWidth="lg">
          <Box sx={{ textAlign: 'center' }}>
            <Typography variant="h2" component="h1" gutterBottom sx={{ fontWeight: 'bold' }}>
              KT 해커톤 2025
            </Typography>
            <Typography variant="h5" paragraph>
              혁신적인 아이디어로 미래를 만들어가세요
            </Typography>
            <Box sx={{ mt: 4 }}>
              <Button
                component={RouterLink}
                to="/registration"
                variant="contained"
                size="large"
                sx={{ mr: 2, mb: 2 }}
              >
                참가 신청하기
              </Button>
              <Button
                component={RouterLink}
                to="/schedule"
                variant="outlined"
                size="large"
                sx={{ color: 'white', borderColor: 'white', mb: 2 }}
              >
                일정 보기
              </Button>
            </Box>
          </Box>
        </Container>
      </Paper>

      {/* Event Info */}
      <Container maxWidth="lg">
        <Grid container spacing={4} sx={{ mb: 6 }}>
          <Grid item xs={12} md={4}>
            <Card sx={{ height: '100%', textAlign: 'center' }}>
              <CardContent>
                <EventIcon sx={{ fontSize: 40, color: 'primary.main', mb: 2 }} />
                <Typography variant="h6" gutterBottom>
                  개최일
                </Typography>
                <Typography variant="body1" color="text.secondary">
                  2025년 9월 1일 ~ 3일
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card sx={{ height: '100%', textAlign: 'center' }}>
              <CardContent>
                <LocationOnIcon sx={{ fontSize: 40, color: 'primary.main', mb: 2 }} />
                <Typography variant="h6" gutterBottom>
                  장소
                </Typography>
                <Typography variant="body1" color="text.secondary">
                  원수 수련원
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card sx={{ height: '100%', textAlign: 'center' }}>
              <CardContent>
                <GroupIcon sx={{ fontSize: 40, color: 'primary.main', mb: 2 }} />
                <Typography variant="h6" gutterBottom>
                  참가비
                </Typography>
                <Typography variant="body1" color="text.secondary">
                  무료
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* Highlights */}
        <Typography variant="h4" gutterBottom sx={{ textAlign: 'center', mb: 4 }}>
          해커톤 하이라이트
        </Typography>
        <Grid container spacing={4} sx={{ mb: 6 }}>
          {highlights.map((highlight, index) => (
            <Grid item xs={12} md={4} key={index}>
              <Card sx={{ height: '100%', textAlign: 'center' }}>
                <CardContent>
                  <Box sx={{ color: 'primary.main', mb: 2 }}>
                    {highlight.icon}
                  </Box>
                  <Typography variant="h6" gutterBottom>
                    {highlight.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {highlight.description}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        {/* CTA Section */}
        <Paper sx={{ p: 4, textAlign: 'center', backgroundColor: 'primary.main', color: 'white' }}>
          <Typography variant="h5" gutterBottom>
            지금 바로 참가 신청하세요!
          </Typography>
          <Typography variant="body1" paragraph>
            신청 기간: 2025년 8월 1일 ~ 8월 20일
          </Typography>
          <Button
            component={RouterLink}
            to="/registration"
            variant="contained"
            size="large"
            sx={{ backgroundColor: 'white', color: 'primary.main', '&:hover': { backgroundColor: 'grey.100' } }}
          >
            참가 신청하기
          </Button>
        </Paper>
      </Container>
    </Box>
  );
};

export default Home; 