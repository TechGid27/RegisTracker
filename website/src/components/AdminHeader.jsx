import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import {
  Box, Drawer, Toolbar, List, Typography, Avatar, Stack,
  ListItem, ListItemButton, ListItemIcon, ListItemText, Divider, Chip
} from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PendingActionsIcon from '@mui/icons-material/PendingActions';
import LayersIcon from '@mui/icons-material/Layers';
import LogoutIcon from '@mui/icons-material/Logout';
import PostAddIcon from '@mui/icons-material/PostAdd';
import ViewListIcon from '@mui/icons-material/ViewList';
import FolderCopyOutlinedIcon from '@mui/icons-material/FolderCopyOutlined';
import AssignmentOutlinedIcon from '@mui/icons-material/AssignmentOutlined';
import { UseAuth } from '../context/AuthContext';

const drawerWidth = 280;

const ADMIN_MENU = [
  { text: 'Dashboard',        icon: <DashboardIcon />,           path: '/admin/dashboard' },
  { text: 'Request Manager',  icon: <PendingActionsIcon />,      path: '/admin/pending' },
  { text: 'Announcements',    icon: <PostAddIcon />,             path: '/admin/announcement-lists' },
  { text: 'Document Types',   icon: <FolderCopyOutlinedIcon />,  path: '/admin/document' },
  { text: 'Requirements',     icon: <LayersIcon />,              path: '/admin/requirements' },
];

const STAFF_MENU = [
  { text: 'Dashboard',        icon: <DashboardIcon />,           path: '/staff/dashboard' },
  { text: 'Request Manager',  icon: <PendingActionsIcon />,      path: '/admin/pending' },
  { text: 'Announcements',    icon: <ViewListIcon />,            path: '/announcements' },
];

export default function AdminHeader() {
  const location = useLocation();
  const navigate = useNavigate();
  const { logout, user } = UseAuth();

  const isStaff = user?.role === 'Staff';
  const menuItems = isStaff ? STAFF_MENU : ADMIN_MENU;

  const handleLogout = async () => {
    try { await logout(); } catch {}
    navigate('/login');
  };

  const initials = user?.firstName?.charAt(0).toUpperCase() ?? 'A';
  const fullName = user ? `${user.firstName} ${user.lastName}` : 'Admin User';
  const roleLabel = user?.role ?? 'Admin';

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
          flexDirection: 'column',
        },
      }}
    >
      {/* Brand */}
      <Toolbar sx={{ my: 2, display: 'flex', justifyContent: 'center' }}>
        <Typography variant="h6" fontWeight={900} color="#1B254B">
          RegisTrack
        </Typography>
      </Toolbar>

      {/* User card */}
      <Box sx={{ px: 2, py: 2.5, mb: 3, bgcolor: '#F4F7FE', borderRadius: 4, display: 'flex', alignItems: 'center', gap: 2 }}>
        <Avatar sx={{ bgcolor: '#1B254B', fontWeight: 800 }}>{initials}</Avatar>
        <Box sx={{ overflow: 'hidden' }}>
          <Typography variant="subtitle2" fontWeight={800} color="#1B254B" noWrap>{fullName}</Typography>
          <Chip
            label={roleLabel}
            size="small"
            sx={{ height: 18, fontSize: '0.65rem', fontWeight: 700, bgcolor: '#E8EAF6', color: '#1A237E', mt: 0.25 }}
          />
        </Box>
      </Box>

      {/* Nav */}
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
                  bgcolor: isActive ? '#EEF2FF' : 'transparent',
                  color: isActive ? '#4318FF' : '#A3AED0',
                  '&:hover': { bgcolor: '#F0F3FF' },
                  transition: '0.2s',
                }}
              >
                <ListItemIcon sx={{ color: isActive ? '#4318FF' : '#A3AED0', minWidth: 40 }}>
                  {React.cloneElement(item.icon, { fontSize: 'small' })}
                </ListItemIcon>
                <ListItemText
                  primary={item.text}
                  primaryTypographyProps={{ fontWeight: isActive ? 700 : 500, fontSize: '0.875rem' }}
                />
              </ListItemButton>
            </ListItem>
          );
        })}
      </List>

      {/* Logout */}
      <Box sx={{ mb: 3 }}>
        <Divider sx={{ mb: 2, borderColor: '#F4F7FE' }} />
        <ListItem disablePadding>
          <ListItemButton
            onClick={handleLogout}
            sx={{ borderRadius: 3, color: '#FF5B5B', '&:hover': { bgcolor: '#FFF5F5' }, transition: '0.2s' }}
          >
            <ListItemIcon sx={{ color: '#FF5B5B', minWidth: 40 }}>
              <LogoutIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText primary="Logout" primaryTypographyProps={{ fontWeight: 700, fontSize: '0.875rem' }} />
          </ListItemButton>
        </ListItem>
      </Box>
    </Drawer>
  );
}
