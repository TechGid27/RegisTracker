import * as React from 'react';
import { 
  AppBar, Box, Toolbar, IconButton, Typography, Menu, Container, 
  Avatar, Button, Tooltip, MenuItem, Badge, Stack, Divider, Chip
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import NotificationsIcon from '@mui/icons-material/Notifications';
import { Link, useLocation, useNavigate } from 'react-router-dom';

// Context Imports
import { UseAuth } from '../context/AuthContext'; 
import { UseRequests } from '../context/RequestContext'; 
import { UseAnnouncements } from '../context/AnnouncementsContext'; 
import { UseMeta } from '../context/MetaContext'; 

function ResponsiveAppBar() {
  const { user, logout } = UseAuth(); 
  const { requests } = UseRequests(); 
  const { announcements } = UseAnnouncements(); 
  const { requirements } = UseMeta(); 
  
  const location = useLocation();
  const navigate = useNavigate();
  const isLoggedIn = !!user;

  // UI States
  const [anchorElNav, setAnchorElNav] = React.useState(null);
  const [anchorElUser, setAnchorElUser] = React.useState(null);
  const [anchorElNotif, setAnchorElNotif] = React.useState(null);

  // 1. INITIALIZE READ IDS (Per Account Persistence)
  const [readIds, setReadIds] = React.useState(() => {
    // Kinahanglan i-check kung kinsay naka-login para sa saktong key
    const userKey = user?.id ? `registrack_read_notifs_${user.id}` : null;
    if (!userKey) return [];
    const saved = localStorage.getItem(userKey);
    return saved ? JSON.parse(saved) : [];
  });

  // Sync state kung mag-change ang user (Log in/Logout)
  React.useEffect(() => {
    if (user?.id) {
      const userKey = `registrack_read_notifs_${user.id}`;
      const saved = localStorage.getItem(userKey);
      setReadIds(saved ? JSON.parse(saved) : []);
    } else {
      setReadIds([]); 
    }
  }, [user?.id]);

  // Save changes sa readIds sa localStorage
  React.useEffect(() => {
    if (user?.id) {
      const userKey = `registrack_read_notifs_${user.id}`;
      localStorage.setItem(userKey, JSON.stringify(readIds));
    }
  }, [readIds, user?.id]);

  // 2. CONSOLIDATE NOTIFICATIONS
  const allNotifications = React.useMemo(() => {
    if (!isLoggedIn) return [];
    const list = [];

    if (requests?.length > 0) {
      requests
        .filter(req => ['Approve', 'Ready', 'Downloaded'].includes(req.status))
        .forEach(req => {
          list.push({
            id: `req-${req.id}-${req.status}`, 
            text: `Ang imong ${req.documentTypeName || 'Request'} kay ${req.status} na.`,
            path: '/dashboard',
            type: 'Request Update',
            color: '#4caf50'
          });
        });
    }

    if (announcements?.length > 0) {
      announcements.forEach(ann => {
        list.push({
          id: `ann-${ann.id}`,
          text: `New Post: ${ann.title}`,
          path: '/announcements',
          type: 'Announcement',
          color: '#2196f3'
        });
      });
    }

    if (requirements?.length > 0) {
       list.push({
         id: 'meta-update-system',
         text: `Palihug susiha ang updated list sa requirements.`,
         path: '/requirements',
         type: 'System Update',
         color: '#ff9800'
       });
    }

    return list;
  }, [requests, announcements, requirements, isLoggedIn]);

  // 3. FILTER UNREAD
  const unreadNotifications = React.useMemo(() => {
    return allNotifications.filter(n => !readIds.includes(n.id));
  }, [allNotifications, readIds]);

  // UI HANDLERS
  const handleOpenNavMenu = (e) => setAnchorElNav(e.currentTarget);
  const handleOpenUserMenu = (e) => setAnchorElUser(e.currentTarget);
  const handleOpenNotifMenu = (e) => setAnchorElNotif(e.currentTarget);
  const handleCloseNavMenu = () => setAnchorElNav(null);
  const handleCloseUserMenu = () => setAnchorElUser(null);
  const handleCloseNotifMenu = () => setAnchorElNotif(null);

  const handleNotifClick = (notif) => {
    setReadIds(prev => [...prev, notif.id]);
    handleCloseNotifMenu();
    navigate(notif.path);
  };

  const handleClearAll = () => {
    const allIds = allNotifications.map(n => n.id);
    setReadIds(allIds);
  };

  const handleMenuClick = (setting) => {
    handleCloseUserMenu();
    if (setting.action === 'logout') {
      logout();
      navigate('/');
    }
  };

  const pages = isLoggedIn 
    ? [
        { name: 'Dashboard', path: '/dashboard' },
        { name: 'Document Request', path: '/new-request' },
        { name: 'Requirements', path: '/requirements' },
        { name: 'Announcement', path: '/announcements' },
      ]
    : [
        { name: 'Track Request', path: '/' },
        { name: 'Requirements', path: '/requirements' },
        { name: 'Announcement', path: '/announcements' },
      ];

  const settings = isLoggedIn 
    ? [
        { name: 'Dashboard', path: '/dashboard' },
        { name: 'Profile', path: '/profile' },
        { name: 'Logout', action: 'logout' }
      ]
    : [
        { name: 'Login', path: '/login' },
        { name: 'Register', path: '/register' }
      ];

  return (
    <AppBar position="sticky" elevation={0} sx={{ 
      backgroundColor: 'rgba(255, 255, 255, 0.85)', 
      backdropFilter: 'blur(12px)', 
      borderBottom: '1px solid rgba(0, 0, 0, 0.08)',
      color: 'black', top: 0, zIndex: 1100 
    }}>
      <Container maxWidth="lg">
        <Toolbar disableGutters sx={{ justifyContent: 'space-between' }}>
          <Typography variant="h6" noWrap component={Link} to="/" sx={{
            mr: 4, display: 'flex', fontWeight: 900, color: '#1A237E', textDecoration: 'none'
          }}>
            Registrack
          </Typography>

          <Box sx={{ flexGrow: 1, display: { xs: 'none', md: 'flex',justifyContent: 'center', alignItems: 'center' }, gap: 1 }}>
            {pages.map((page) => (
              <Button key={page.name} component={Link} to={page.path} sx={{ 
                my: 2, px: 2, 
                color: location.pathname === page.path ? '#1A237E' : '#555', 
                fontWeight: location.pathname === page.path ? 800 : 500,
                textTransform: 'none'
              }}>
                {page.name}
              </Button>
            ))}
          </Box>

          <Box sx={{ flexGrow: 0, display: 'flex', alignItems: 'center', gap: 1.5 }}>
            {isLoggedIn && (
              <>
                <Tooltip title="Notifications">
                  <IconButton onClick={handleOpenNotifMenu}>
                    <Badge badgeContent={unreadNotifications.length} color="error">
                      <NotificationsIcon sx={{ color: '#1A237E' }} />
                    </Badge>
                  </IconButton>
                </Tooltip>
                
                <Menu
                  anchorEl={anchorElNotif}
                  open={Boolean(anchorElNotif)}
                  onClose={handleCloseNotifMenu}
                  PaperProps={{ sx: { width: 320, borderRadius: 4, mt: 1.5 } }}
                  anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
                  transformOrigin={{ vertical: 'top', horizontal: 'right' }}
                >
                  <Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ px: 2, py: 1 }}>
                    <Typography variant="subtitle1" fontWeight={800}>Updates</Typography>
                    {unreadNotifications.length > 0 && (
                      <Button onClick={handleClearAll} size="small" sx={{ textTransform: 'none' }}>Clear All</Button>
                    )}
                  </Stack>
                  <Divider />
                  <Box sx={{ maxHeight: 350, overflowY: 'auto' }}>
                    {unreadNotifications.length > 0 ? (
                      unreadNotifications.map((notif) => (
                        <MenuItem key={notif.id} onClick={() => handleNotifClick(notif)} sx={{ whiteSpace: 'normal' }}>
                          <Stack spacing={0.5}>
                            <Chip label={notif.type} size="small" sx={{ bgcolor: notif.color, color: 'white', fontWeight: 700, height: 20 }} />
                            <Typography variant="body2">{notif.text}</Typography>
                          </Stack>
                        </MenuItem>
                      ))
                    ) : (
                      <Typography sx={{ p: 3, textAlign: 'center', color: 'text.secondary' }}>Clean as a whistle! 🎉</Typography>
                    )}
                  </Box>
                </Menu>
              </>
            )}

            <IconButton onClick={handleOpenUserMenu} sx={{ p: 0.5 }}>
              <Avatar alt={user?.name} src={user?.photoURL} sx={{ bgcolor: isLoggedIn ? '#1A237E' : '#CCC' }}>
                {isLoggedIn ? user?.name?.charAt(0).toUpperCase() : null}
              </Avatar>
            </IconButton>
            
            <Menu
              anchorEl={anchorElUser} open={Boolean(anchorElUser)} onClose={handleCloseUserMenu}
              sx={{ mt: '45px' }} anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
            >
              {settings.map((s) => (
                <MenuItem key={s.name} component={s.path ? Link : 'li'} to={s.path} onClick={() => handleMenuClick(s)}>
                  <Typography color={s.action === 'logout' ? 'error' : 'inherit'}>{s.name}</Typography>
                </MenuItem>
              ))}
            </Menu>
          </Box>
        </Toolbar>
      </Container>
    </AppBar>
  );
}

export default ResponsiveAppBar;