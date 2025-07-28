import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Chip,
  TextField,
  InputAdornment,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Alert,
  CircularProgress
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import axios from 'axios';

const Participants = () => {
  const [participants, setParticipants] = useState([]);
  const [filteredParticipants, setFilteredParticipants] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');

  useEffect(() => {
    fetchParticipants();
  }, []);

  const filterParticipants = React.useCallback(() => {
    let filtered = participants;

    // Status filter
    if (statusFilter !== 'ALL') {
      filtered = filtered.filter(participant => participant.status === statusFilter);
    }

    // Search filter
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      filtered = filtered.filter(participant =>
        participant.name.toLowerCase().includes(term) ||
        participant.teamName.toLowerCase().includes(term) ||
        participant.projectTitle.toLowerCase().includes(term) ||
        participant.organization.toLowerCase().includes(term)
      );
    }

    setFilteredParticipants(filtered);
  }, [participants, searchTerm, statusFilter]);

  useEffect(() => {
    filterParticipants();
  }, [filterParticipants]);

  const fetchParticipants = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/participants');
      setParticipants(response.data);
      setError('');
    } catch (error) {
      setError('참가자 목록을 불러오는 중 오류가 발생했습니다.');
      console.error('Error fetching participants:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'APPROVED':
        return 'success';
      case 'PENDING':
        return 'warning';
      case 'REJECTED':
        return 'error';
      default:
        return 'default';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'APPROVED':
        return '승인됨';
      case 'PENDING':
        return '대기중';
      case 'REJECTED':
        return '거절됨';
      default:
        return status;
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ textAlign: 'center', mb: 4 }}>
        참가자 목록
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {/* Filters */}
      <Paper sx={{ p: 3, mb: 4 }}>
        <Grid container spacing={3} alignItems="center">
          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label="검색"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon />
                  </InputAdornment>
                ),
              }}
              placeholder="이름, 팀명, 프로젝트 제목, 소속으로 검색"
            />
          </Grid>
          <Grid item xs={12} md={3}>
            <FormControl fullWidth>
              <InputLabel>상태</InputLabel>
              <Select
                value={statusFilter}
                label="상태"
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <MenuItem value="ALL">전체</MenuItem>
                <MenuItem value="PENDING">대기중</MenuItem>
                <MenuItem value="APPROVED">승인됨</MenuItem>
                <MenuItem value="REJECTED">거절됨</MenuItem>
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} md={3}>
            <Typography variant="body2" color="text.secondary">
              총 {filteredParticipants.length}명의 참가자
            </Typography>
          </Grid>
        </Grid>
      </Paper>

      {/* Participants Table */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ backgroundColor: 'primary.main' }}>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>번호</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>이름</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>팀명</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>프로젝트 제목</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>소속</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>상태</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>신청일</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredParticipants.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} align="center" sx={{ py: 4 }}>
                  <Typography variant="body1" color="text.secondary">
                    {searchTerm || statusFilter !== 'ALL' 
                      ? '검색 조건에 맞는 참가자가 없습니다.' 
                      : '등록된 참가자가 없습니다.'}
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              filteredParticipants.map((participant, index) => (
                <TableRow key={participant.id} hover>
                  <TableCell>{index + 1}</TableCell>
                  <TableCell>
                    <Typography variant="body2" fontWeight="medium">
                      {participant.name}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      {participant.email}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" fontWeight="medium">
                      {participant.teamName}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" fontWeight="medium">
                      {participant.projectTitle}
                    </Typography>
                    <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>
                      {participant.projectDescription.length > 50 
                        ? `${participant.projectDescription.substring(0, 50)}...` 
                        : participant.projectDescription}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2">
                      {participant.organization}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      {participant.position}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={getStatusText(participant.status)}
                      color={getStatusColor(participant.status)}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2">
                      {new Date(participant.registrationDate).toLocaleDateString('ko-KR')}
                    </Typography>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Statistics */}
      <Grid container spacing={3} sx={{ mt: 4 }}>
        <Grid item xs={12} md={3}>
          <Card sx={{ textAlign: 'center' }}>
            <CardContent>
              <Typography variant="h4" color="primary">
                {participants.length}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                총 참가자
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={3}>
          <Card sx={{ textAlign: 'center' }}>
            <CardContent>
              <Typography variant="h4" color="warning.main">
                {participants.filter(p => p.status === 'PENDING').length}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                대기중
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={3}>
          <Card sx={{ textAlign: 'center' }}>
            <CardContent>
              <Typography variant="h4" color="success.main">
                {participants.filter(p => p.status === 'APPROVED').length}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                승인됨
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={3}>
          <Card sx={{ textAlign: 'center' }}>
            <CardContent>
              <Typography variant="h4" color="error.main">
                {participants.filter(p => p.status === 'REJECTED').length}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                거절됨
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Participants; 