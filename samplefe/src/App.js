import React from 'react';
import { Routes, Route } from 'react-router-dom';
import { Container } from '@mui/material';
import Header from './components/Header';
import Home from './pages/Home';
import Registration from './pages/Registration';
import Schedule from './pages/Schedule';
import Participants from './pages/Participants';
import Footer from './components/Footer';

function App() {
  return (
    <div className="App">
      <Header />
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4, minHeight: '70vh' }}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/registration" element={<Registration />} />
          <Route path="/schedule" element={<Schedule />} />
          <Route path="/participants" element={<Participants />} />
        </Routes>
      </Container>
      <Footer />
    </div>
  );
}

export default App; 