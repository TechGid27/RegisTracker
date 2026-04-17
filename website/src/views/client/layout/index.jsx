import React from 'react';
import { Box } from '@mui/material';
import { Outlet } from 'react-router-dom';
import Header from '../../../components/Header'; // I-adjust ang path base sa imong folder
// import Footer from '../components/Footer'; // Optional: kung naay separate footer component

export default function MainLayout() {
  return (
    <Box sx={{ bgcolor: '#fbfbfb', minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Permanent Header */}
      <Header />

      {/* Dynamic Content: Diri mugawas ang dashboard.jsx o uban pang pages */}
      <Box component="main" sx={{ flexGrow: 1 }}>
        <Outlet />
      </Box>

      {/* Footer can also be placed here if permanent */}
    </Box>
  );
}