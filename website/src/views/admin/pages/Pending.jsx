import React, { useEffect, useState, useMemo } from 'react';
import { 
  Box, Typography, Stack, Card, IconButton, Chip, 
  CircularProgress, TextField, InputAdornment, Button,
  Dialog, DialogContent, DialogTitle, Tabs, Tab
} from '@mui/material';

// Icons
import SearchIcon from '@mui/icons-material/Search';
import VisibilityIcon from '@mui/icons-material/Visibility';
import RefreshIcon from '@mui/icons-material/Refresh';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import FilterListIcon from '@mui/icons-material/FilterList';

import { UseRequests } from '../../../context/RequestContext'; 
import UpdateRequest from './updaterequest';

export default function AllRequests() {
  const { requests, loading, error, loadRequests } = UseRequests();
  
  const [searchTerm, setSearchTerm] = useState('');
  const [openModal, setOpenModal] = useState(false);
  const [selectedId, setSelectedId] = useState(null);

  const [currentTab, setCurrentTab] = useState('All');

  useEffect(() => {
    loadRequests();
  }, [loadRequests]);

  const filteredData = useMemo(() => {
    return requests.filter(r => {
      const matchesSearch = 
        r.userName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        r.referenceNumber?.toLowerCase().includes(searchTerm.toLowerCase());
      
      const matchesTab = currentTab === 'All' || r.status === currentTab;
      
      return matchesSearch && matchesTab;
    });
  }, [requests, searchTerm, currentTab]);

  const handleOpenUpdate = (id) => {
    setSelectedId(id);
    setOpenModal(true);
  };

  const handleCloseModal = () => {
    setOpenModal(false);
    setSelectedId(null);
  };

  // Helper para sa color sa Chip base sa status
  const getStatusColor = (status) => {
    switch (status) {
      case 'Request': return { bg: '#E1F5FE', text: '#01579B' }; // Blue
      case 'InProcess': return { bg: '#FFF3E0', text: '#E65100' }; // Orange
      case 'Approve': return { bg: '#E8F5E9', text: '#1B5E20' }; // Green
      case 'Receive': return { bg: '#F3E5F5', text: '#4A148C' }; // Purple
      default: return { bg: '#F4F7FE', text: '#707EAE' };
    }
  };

  return (
    <Box sx={{ p: 1 }}>
      {/* Header Section */}
      <Box sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <Box>
          <Typography variant="h4" fontWeight="800" color="#1B254B">Request Manager</Typography>
          <Typography color="text.secondary">
            Monitor and process all student document requests in one place.
          </Typography>
        </Box>
        <Button 
          startIcon={<RefreshIcon />} 
          onClick={() => loadRequests()}
          variant="contained"
          sx={{ 
            borderRadius: 3, 
            textTransform: 'none', 
            fontWeight: 'bold',
            bgcolor: '#4318FF',
            '&:hover': { bgcolor: '#3311CC' }
          }}
        >
          Sync Data
        </Button>
      </Box>

      <Tabs 
        value={currentTab} 
        onChange={(e, newVal) => setCurrentTab(newVal)}
        sx={{ 
          mb: 3,
          '& .MuiTab-root': { textTransform: 'none', fontWeight: '700', fontSize: '1rem' },
          '& .Mui-selected': { color: '#4318FF !important' },
          '& .MuiTabs-indicator': { bgcolor: '#4318FF', height: 3, borderRadius: '3px' }
        }}
      >
        <Tab label="All Requests" value="All" />
        <Tab label="Pending Request" value="Request" />
        <Tab label="In Progress" value="InProcess" />
        <Tab label="Approved" value="Approve" />
        <Tab label="Received" value="Receive" />
        <Tab label="Completed" value="Download" />
      </Tabs>

      {/* Search Bar */}
      <TextField
        fullWidth
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        placeholder="Search student or reference number..."
        variant="outlined"
        sx={{ 
          mb: 4, 
          bgcolor: 'white', 
          borderRadius: 4,
          '& .MuiOutlinedInput-root': {
            borderRadius: 4,
            boxShadow: '0 4px 20px rgba(0,0,0,0.05)',
            border: '1px solid #E0E5F2'
          },
          '& fieldset': { border: 'none' }
        }}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SearchIcon sx={{ color: '#4318FF' }} />
            </InputAdornment>
          ),
        }}
      />

      {/* Content Section */}
      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}>
          <CircularProgress sx={{ color: '#4318FF' }} />
        </Box>
      ) : filteredData.length === 0 ? (
        <Card sx={{ p: 8, textAlign: 'center', borderRadius: 6, border: '2px dashed #E0E4EC', bgcolor: 'transparent' }}>
          <Typography variant="h6" color="text.secondary" fontWeight="600">
            {searchTerm ? `No results for "${searchTerm}"` : `No ${currentTab} requests found.`}
          </Typography>
        </Card>
      ) : (
        <Stack spacing={2.5}>
          {filteredData.map((req) => {
            const statusStyle = getStatusColor(req.status);
            return (
              <Card 
                key={req.id} 
                sx={{ 
                  p: 3, 
                  borderRadius: 5, 
                  display: 'flex', 
                  flexDirection: { xs: 'column', md: 'row' },
                  justifyContent: 'space-between', 
                  alignItems: { xs: 'flex-start', md: 'center' },
                  gap: 2,
                  transition: '0.3s',
                  border: '1px solid #E0E5F2',
                  '&:hover': { boxShadow: '0 12px 30px rgba(0,0,0,0.08)', transform: 'translateY(-2px)' }
                }}
              >
                <Stack direction="row" spacing={3} alignItems="center">
                  <Box sx={{ 
                    p: 2, 
                    bgcolor: statusStyle.bg, 
                    borderRadius: 4, 
                    color: statusStyle.text,
                    display: 'flex'
                  }}>
                    <FilterListIcon />
                  </Box>
                  <Box>
                    <Typography variant="h6" fontWeight="800" color="#1B254B">
                      {req.documentTypeName}
                    </Typography>
                    <Typography variant="body2" color="text.secondary" fontWeight="600">
                      {req.userName} • <Typography component="span" variant="body2" sx={{ color: '#4318FF', fontWeight: '800' }}>{req.referenceNumber}</Typography>
                    </Typography>
                  </Box>
                </Stack>

                <Stack direction="row" spacing={3} alignItems="center" sx={{ width: { xs: '100%', md: 'auto' }, justifyContent: 'space-between' }}>
                  <Box sx={{ textAlign: 'left', minWidth: '120px' }}>
                    <Typography variant="caption" fontWeight="bold" color="#A3AED0">STATUS</Typography>
                    <Box>
                      <Chip 
                        label={req.status} 
                        size="small"
                        sx={{ 
                          bgcolor: statusStyle.bg, 
                          color: statusStyle.text, 
                          fontWeight: '800',
                          borderRadius: '8px',
                          fontSize: '0.75rem'
                        }} 
                      />
                    </Box>
                  </Box>

                  <Box sx={{ textAlign: 'left', display: { xs: 'none', lg: 'block' } }}>
                    <Typography variant="caption" fontWeight="bold" color="#A3AED0">REQUESTED ON</Typography>
                    <Typography variant="body2" fontWeight="700" color="#1B254B">
                      {new Date(req.requestDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                    </Typography>
                  </Box>

                  <Button 
                    variant="contained"
                    onClick={() => handleOpenUpdate(req.id)}
                    startIcon={<VisibilityIcon />}
                    sx={{ 
                      borderRadius: '12px', 
                      bgcolor: '#F4F7FE', 
                      color: '#4318FF',
                      boxShadow: 'none',
                      textTransform: 'none',
                      fontWeight: '800',
                      '&:hover': { bgcolor: '#4318FF', color: 'white' }
                    }}
                  >
                    Manage
                  </Button>
                </Stack>
              </Card>
            );
          })}
        </Stack>
      )}

      {/* ✅ Modal remains the same but handles all statuses */}
      <Dialog 
        open={openModal} 
        onClose={handleCloseModal}
        maxWidth="md"
        fullWidth
        PaperProps={{ sx: { borderRadius: 6, p: 1 } }}
      >
        <DialogTitle sx={{ fontWeight: '800', color: '#1B254B', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          Update Request Status
          <IconButton onClick={handleCloseModal} size="small"><ArrowBackIcon /></IconButton>
        </DialogTitle>
        <DialogContent>
          {selectedId && (
            <UpdateRequest 
              idFromProp={selectedId} 
              isModal={true} 
              onClose={handleCloseModal} 
            />
          )}
        </DialogContent>
      </Dialog>
    </Box>
  );
}