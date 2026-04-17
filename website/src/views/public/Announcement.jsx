import React, { useState } from 'react';
import { 
  Box, Typography, Container, Stack, Card, 
  CardContent, Chip, Divider, TextField, 
  InputAdornment, CircularProgress 
} from '@mui/material';

// Icons
import CampaignIcon from '@mui/icons-material/Campaign';
import EventIcon from '@mui/icons-material/Event';
import SearchIcon from '@mui/icons-material/Search';
import NotificationsActiveIcon from '@mui/icons-material/NotificationsActive';
import InfoIcon from '@mui/icons-material/Info';
import UpdateIcon from '@mui/icons-material/Update';

import { UseAnnouncements } from '../../context/AnnouncementsContext'; 

const Announcement = () => {

  const { announcements, loading } = UseAnnouncements(); 
  const [searchQuery, setSearchQuery] = useState("");

  const getIcon = (category) => {
    switch (category?.toLowerCase()) {
      case 'enrollment': return <EventIcon />;
      case 'system update': return <UpdateIcon />;
      default: return <CampaignIcon />;
    }
  };

  const filteredAnnouncements = (announcements || []).filter((item) => {

    const title = (item.title || "").toLowerCase();
    const content = (item.content || "").toLowerCase();
    const category = (item.category || "").toLowerCase();
    const search = searchQuery.toLowerCase();

    return (
      title.includes(search) ||
      content.includes(search) ||
      category.includes(search)
    );
  });

  return (
    <Box sx={{ bgcolor: '#F0F2F5', minHeight: '100vh', pb: 10 }}>
      {/* Hero Section */}
      <Box sx={{ 
        background: 'linear-gradient(135deg, #1A237E 0%, #311B92 100%)', 
        color: 'white', 
        pt: 12, pb: 15,
        textAlign: 'center',
        clipPath: 'ellipse(100% 70% at 50% 30%)'
      }}>
        <Container maxWidth="md">
          <NotificationsActiveIcon sx={{ fontSize: 50, mb: 2, color: '#FFD600' }} />
          <Typography variant="h2" sx={{ fontWeight: 900, mb: 1, fontSize: { xs: '2.5rem', md: '3.75rem' } }}>
            Announcements
          </Typography>
          <Typography variant="h6" sx={{ opacity: 0.8, fontWeight: 400 }}>
            Pabilin nga updated sa pinakaulahing balita gikan sa Registrar's Office.
          </Typography>
        </Container>
      </Box>

      <Container maxWidth="md" sx={{ mt: 8 }}>
        {/* Search Bar */}
        <Box sx={{ 
          bgcolor: 'white', 
          p: 2, 
          borderRadius: 4, 
          boxShadow: '0 10px 30px rgba(0,0,0,0.1)',
          mb: 5
        }}>
          <TextField 
            fullWidth 
            placeholder="Search announcements..." 
            variant="standard"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            InputProps={{
              disableUnderline: true,
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon sx={{ color: 'text.secondary', ml: 1 }} />
                </InputAdornment>
              ),
              sx: { fontSize: '1.1rem', py: 1}
            }}
          />
        </Box>

        {/* Loading State */}
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 5 }}>
            <CircularProgress sx={{ color: '#1A237E' }} />
          </Box>
        ) : (
          <Stack spacing={4}>
            {filteredAnnouncements.length > 0 ? (
              filteredAnnouncements.map((news) => (
                <Card key={news.id} sx={{ 
                  borderRadius: 5, 
                  border: '1px solid rgba(0,0,0,0.05)',
                  boxShadow: '0 4px 20px rgba(0,0,0,0.03)',
                  transition: '0.3s',
                  position: 'relative',
                  '&:hover': { transform: 'scale(1.01)', boxShadow: '0 10px 30px rgba(0,0,0,0.08)' }
                }}>
                  <CardContent sx={{ p: 4 }}>
                    <Stack direction="row" justifyContent="space-between" alignItems="start" sx={{ mb: 2 }}>
                      <Stack direction="row" spacing={2} alignItems="center">
                        <Box sx={{ 
                          p: 1.5, 
                          borderRadius: 3, 
                          bgcolor: 'rgba(26, 35, 126, 0.1)', 
                          color: '#1A237E',
                          display: 'flex'
                        }}>
                          {getIcon(news.category)}
                        </Box>
                        <Box>
                          <Typography variant="caption" sx={{ fontWeight: 700, color: 'text.secondary', textTransform: 'uppercase' }}>
                            {news.category}
                          </Typography>
                          <Typography variant="h5" sx={{ fontWeight: 800, color: '#1A237E' }}>
                            {news.title}
                          </Typography>
                        </Box>
                      </Stack>
                      <Chip 
                        label={news.status || "General"} 
                        size="small"
                        sx={{ 
                          fontWeight: 700, 
                          bgcolor: news.status === 'Priority' ? '#ffebee' : news.status === 'Important' ? '#fff3e0' : '#e3f2fd',
                          color: news.status === 'Priority' ? '#d32f2f' : news.status === 'Important' ? '#ef6c00' : '#1976d2',
                        }} 
                      />
                    </Stack>

                    <Typography variant="body1" color="text.secondary" sx={{ mb: 3, lineHeight: 1.7 }}>
                      {news.content}
                    </Typography>

                    <Divider sx={{ my: 2, borderStyle: 'dashed' }} />

                    <Stack direction="row" justifyContent="space-between" alignItems="center">
                      <Typography variant="caption" sx={{ display: 'flex', alignItems: 'center', gap: 0.5, color: 'text.disabled' }}>
                        <InfoIcon sx={{ fontSize: 14 }} /> Posted on {news.date || new Date(news.createdAt).toLocaleDateString()}
                      </Typography>
                      <Typography variant="button" sx={{ cursor: 'pointer', fontWeight: 700, color: '#1A237E', fontSize: '0.75rem' }}>
                        Read More
                      </Typography>
                    </Stack>
                  </CardContent>
                </Card>
              ))
            ) : (
              <Box sx={{ textAlign: 'center', py: 10 }}>
                <Typography variant="h6" color="text.secondary">Walay nakit-an nga announcement.</Typography>
              </Box>
            )}
          </Stack>
        )}
      </Container>
    </Box>
  );
};

export default Announcement;