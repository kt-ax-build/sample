import React from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Chip,
  Paper
} from '@mui/material';
import {
  Timeline,
  TimelineItem,
  TimelineSeparator,
  TimelineConnector,
  TimelineContent,
  TimelineDot,
  TimelineOppositeContent
} from '@mui/lab';
import EventIcon from '@mui/icons-material/Event';
import RestaurantIcon from '@mui/icons-material/Restaurant';
import CodeIcon from '@mui/icons-material/Code';
import MicIcon from '@mui/icons-material/Mic';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';

const Schedule = () => {
  const scheduleData = [
    {
      date: '9월 1일 (월)',
      day: 'DAY 1',
      events: [
        { time: '09:00 ~ 10:00', title: '등록', icon: <EventIcon />, color: 'primary' },
        { time: '10:00 ~ 11:00', title: '개회식', icon: <EventIcon />, color: 'primary' },
        { time: '11:00 ~ 12:00', title: '해커톤 소개 및 주제 발표', icon: <MicIcon />, color: 'secondary' },
        { time: '12:00 ~ 13:00', title: '점심 식사', icon: <RestaurantIcon />, color: 'success' },
        { time: '13:00 ~ 18:00', title: '팀 빌딩 및 아이디어 브레인스토밍', icon: <CodeIcon />, color: 'info' }
      ]
    },
    {
      date: '9월 2일 (화)',
      day: 'DAY 2',
      events: [
        { time: '09:00 ~ 12:00', title: '개발 시간', icon: <CodeIcon />, color: 'info' },
        { time: '12:00 ~ 13:00', title: '점심 식사', icon: <RestaurantIcon />, color: 'success' },
        { time: '13:00 ~ 18:00', title: '개발 시간', icon: <CodeIcon />, color: 'info' }
      ]
    },
    {
      date: '9월 3일 (수)',
      day: 'DAY 3',
      events: [
        { time: '09:00 ~ 12:00', title: '개발 마감 및 제출', icon: <CodeIcon />, color: 'warning' },
        { time: '12:00 ~ 13:00', title: '점심 식사', icon: <RestaurantIcon />, color: 'success' },
        { time: '13:00 ~ 15:00', title: '발표 준비', icon: <MicIcon />, color: 'secondary' },
        { time: '15:00 ~ 17:00', title: '팀 발표 및 심사', icon: <MicIcon />, color: 'secondary' },
        { time: '17:00 ~ 18:00', title: '시상식 및 폐회식', icon: <EmojiEventsIcon />, color: 'success' }
      ]
    }
  ];

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ textAlign: 'center', mb: 4 }}>
        해커톤 일정
      </Typography>

      <Paper sx={{ p: 4, mb: 4 }}>
        <Typography variant="h6" gutterBottom>
          📅 전체 일정 개요
        </Typography>
        <Grid container spacing={3}>
          <Grid item xs={12} md={4}>
            <Card sx={{ textAlign: 'center', height: '100%' }}>
              <CardContent>
                <Typography variant="h6" color="primary" gutterBottom>
                  DAY 1
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  등록 및 팀 빌딩
                </Typography>
                <Chip label="9월 1일" color="primary" sx={{ mt: 1 }} />
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card sx={{ textAlign: 'center', height: '100%' }}>
              <CardContent>
                <Typography variant="h6" color="info" gutterBottom>
                  DAY 2
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  집중 개발
                </Typography>
                <Chip label="9월 2일" color="info" sx={{ mt: 1 }} />
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card sx={{ textAlign: 'center', height: '100%' }}>
              <CardContent>
                <Typography variant="h6" color="success" gutterBottom>
                  DAY 3
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  발표 및 시상
                </Typography>
                <Chip label="9월 3일" color="success" sx={{ mt: 1 }} />
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </Paper>

      {scheduleData.map((day, dayIndex) => (
        <Paper key={dayIndex} sx={{ p: 4, mb: 4 }}>
          <Typography variant="h5" gutterBottom sx={{ color: 'primary.main', mb: 3 }}>
            {day.day} - {day.date}
          </Typography>
          
          <Timeline position="alternate">
            {day.events.map((event, eventIndex) => (
              <TimelineItem key={eventIndex}>
                <TimelineOppositeContent sx={{ m: 'auto 0' }} variant="body2" color="text.secondary">
                  {event.time}
                </TimelineOppositeContent>
                <TimelineSeparator>
                  <TimelineDot color={event.color}>
                    {event.icon}
                  </TimelineDot>
                  {eventIndex < day.events.length - 1 && <TimelineConnector />}
                </TimelineSeparator>
                <TimelineContent sx={{ py: '12px', px: 2 }}>
                  <Typography variant="h6" component="span">
                    {event.title}
                  </Typography>
                </TimelineContent>
              </TimelineItem>
            ))}
          </Timeline>
        </Paper>
      ))}

      <Paper sx={{ p: 4, backgroundColor: 'primary.main', color: 'white' }}>
        <Typography variant="h6" gutterBottom>
          🎯 참가 혜택
        </Typography>
        <Grid container spacing={2}>
          <Grid item xs={12} md={6}>
            <Typography variant="body1" paragraph>
              • 참가자 전원에게 KT 기념품 제공
            </Typography>
          </Grid>
          <Grid item xs={12} md={6}>
            <Typography variant="body1" paragraph>
              • 우수 팀에게 상장 및 상품 제공
            </Typography>
          </Grid>
        </Grid>
      </Paper>
    </Box>
  );
};

export default Schedule; 