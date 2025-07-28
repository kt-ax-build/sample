import React from 'react';
import {
  Box,
  Container,
  Typography,
  Grid,
  Divider
} from '@mui/material';
import EmailIcon from '@mui/icons-material/Email';
import PhoneIcon from '@mui/icons-material/Phone';

const Footer = () => {
  return (
    <Box
      component="footer"
      sx={{
        backgroundColor: '#f5f5f5',
        py: 6,
        mt: 'auto'
      }}
    >
      <Container maxWidth="lg">
        <Grid container spacing={4}>
          <Grid item xs={12} md={6}>
            <Typography variant="h6" color="text.primary" gutterBottom>
              KT 해커톤 2025
            </Typography>
            <Typography variant="body2" color="text.secondary">
              혁신적인 아이디어로 미래를 만들어가세요
            </Typography>
            <Box sx={{ mt: 2 }}>
              <Typography variant="body2" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <EmailIcon sx={{ mr: 1, fontSize: 'small' }} />
                kt-hackathon@kt.com
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ display: 'flex', alignItems: 'center' }}>
                <PhoneIcon sx={{ mr: 1, fontSize: 'small' }} />
                02-1234-5678
              </Typography>
            </Box>
          </Grid>
          <Grid item xs={12} md={6}>
            <Typography variant="h6" color="text.primary" gutterBottom>
              주최 및 후원
            </Typography>
            <Typography variant="body2" color="text.secondary" paragraph>
              주최: KT
            </Typography>
            <Typography variant="body2" color="text.secondary" paragraph>
              주관: KT AX Build TF
            </Typography>
            <Typography variant="body2" color="text.secondary">
              후원: KT, KT Cloud, KT DS, KT M&S, KT Skylife
            </Typography>
          </Grid>
        </Grid>
        <Divider sx={{ my: 3 }} />
        <Typography variant="body2" color="text.secondary" align="center">
          © 2025 KT Corporation. All rights reserved.
        </Typography>
      </Container>
    </Box>
  );
};

export default Footer; 