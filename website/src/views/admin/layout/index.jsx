import { Outlet } from 'react-router-dom';
import { Box, Toolbar } from '@mui/material';
import AdminHeader from '../../../components/AdminHeader';

const drawerWidth = 280; 

export default function index() {
  return (
    <Box sx={{ display: 'flex' }}>
      <AdminHeader />
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          minHeight: '100vh',
          bgcolor: '#F4F7FE'
        }}
      >
        <Outlet />
      </Box>
    </Box>
  );
}