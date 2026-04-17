import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { 
  Box, Drawer, Toolbar, List, Typography, Avatar, Stack, 
  ListItem, ListItemButton, ListItemIcon, ListItemText, Divider 
} from '@mui/material';

import DashboardIcon from '@mui/icons-material/Dashboard';
import PendingActionsIcon from '@mui/icons-material/PendingActions';
import LayersIcon from '@mui/icons-material/Layers';
import LogoutIcon from '@mui/icons-material/Logout';
import { UseAuth } from '../context/AuthContext'; 
import PostAddIcon from '@mui/icons-material/PostAdd';
import ViewListIcon from '@mui/icons-material/ViewList';

const drawerWidth = 280;

const AdminHeader = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { logout } = UseAuth(); // Kuhaon ang logout function

  const menuItems = [
    { text: 'Dashboard', icon: <DashboardIcon sx={{ color: '#4318FF' }} />, path: '/admin/dashboard' },
    { text: 'Request Manage', icon: <PendingActionsIcon sx={{ color: '#4318FF' }} />, path: '/admin/pending' },
    { text: 'Announcement Post', icon: <PostAddIcon sx={{ color: '#4318FF' }} />, path: '/admin/announcement-post' },
    { text: 'Announcement List', icon: <ViewListIcon sx={{ color: '#4318FF' }} />, path: '/admin/announcement-lists' },
     { text: 'Documentation Requirements', icon: <LayersIcon sx={{ color: '#4318FF' }} />, path: '/admin/document' },
  ];

  const handleLogout = async () => {
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      console.error("Logout failed:", error);
    }
  };

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        '& .MuiDrawer-paper': { 
          width: drawerWidth, 
          boxSizing: 'border-box', 
          bgcolor: 'white', 
          borderRight: '1px solid #E0E4EC',
          px: 2,
          display: 'flex',
          flexDirection: 'column' // Importante para sa positioning sa logout
        },
      }}
    >
      {/* Brand Logo Section */}
      <Toolbar sx={{ my: 2, display: 'flex', justifyContent: 'center' }}>
        <Stack direction="row" alignItems="center" spacing={1.5}>
          <Typography variant="h6" fontWeight="800" color="#1B254B">
            Admin Portal
          </Typography>
        </Stack>
      </Toolbar>

      {/* Admin Profile Card */}
      <Box sx={{ 
        px: 2, py: 2.5, mb: 4, 
        bgcolor: '#F4F7FE', 
        borderRadius: 4, 
        display: 'flex', 
        alignItems: 'center', 
        gap: 2 
      }}>
        <Avatar sx={{ bgcolor: '#1B254B', fontWeight: 'bold' }}>A</Avatar>
        <Box>
          <Typography variant="subtitle2" fontWeight="800" color="#1B254B">Admin User</Typography>
          <Typography variant="caption" color="#A3AED0">Registrar Office</Typography>
        </Box>
      </Box>

      {/* Navigation Menu */}
      <List sx={{ flexGrow: 1 }}>
        {menuItems.map((item) => {
          const isActive = location.pathname === item.path;
          return (
            <ListItem key={item.text} disablePadding sx={{ mb: 0.5 }}>
              <ListItemButton 
                component={Link} 
                to={item.path} 
                sx={{ 
                  borderRadius: 3,
                  bgcolor: isActive ? '#F4F7FE' : 'transparent',
                  color: isActive ? '#4318FF' : '#A3AED0',
                  '&:hover': { bgcolor: '#F0F3FF' },
                  transition: '0.2s ease-in-out'
                }}
              >
                <ListItemIcon sx={{ color: isActive ? '#4318FF' : '#A3AED0', minWidth: 45 }}>
                  {item.icon}
                </ListItemIcon>
                <ListItemText 
                  primary={item.text} 
                  primaryTypographyProps={{ fontWeight: isActive ? '700' : '500', fontSize: '0.9rem' }} 
                />
              </ListItemButton>
            </ListItem>
          );
        })}
      </List>

      {/* --- LOGOUT SECTION --- */}
      <Box sx={{ mb: 3 }}>
        <Divider sx={{ mb: 2, borderColor: '#F4F7FE' }} />
        <ListItem disablePadding>
          <ListItemButton 
            onClick={handleLogout}
            sx={{ 
              borderRadius: 3,
              color: '#FF5B5B', // Pula para sa logout
              '&:hover': { bgcolor: '#FFF5F5' },
              transition: '0.2s ease-in-out'
            }}
          >
            <ListItemIcon sx={{ color: '#FF5B5B', minWidth: 45 }}>
              <LogoutIcon />
            </ListItemIcon>
            <ListItemText 
              primary="Logout" 
              primaryTypographyProps={{ fontWeight: '700', fontSize: '0.9rem' }} 
            />
          </ListItemButton>
        </ListItem>
      </Box>
    </Drawer>
  );
};

export default AdminHeader;