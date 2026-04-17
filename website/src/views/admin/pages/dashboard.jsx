import React, { useEffect, useMemo } from 'react';
import { 
  Box, Grid, Typography, Card, Stack, Avatar, IconButton, 
  TextField, Button, CircularProgress 
} from '@mui/material';

// Icons
import PendingActionsIcon from '@mui/icons-material/PendingActions';
import NotificationsIcon from '@mui/icons-material/Notifications';
import SearchIcon from '@mui/icons-material/Search';
import VisibilityIcon from '@mui/icons-material/Visibility';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

import { UseRequests } from '../../../context/RequestContext';

export default function AdminDashboard() {
  const { requests, loading, error, loadRequests } = UseRequests();

  useEffect(() => {
    loadRequests();
  }, [loadRequests]);

  const dynamicStats = useMemo(() => {
    const counts = {
      request: requests.filter(r => r.status === 'Request').length,
      inProcess: requests.filter(r => r.status === 'InProcess').length,
      approved: requests.filter(r => r.status === 'Approve').length,
      received: requests.filter(r => r.status === 'Receive').length,
      downloaded: requests.filter(r => r.status === 'Download').length,
    };

    return [
      { label: 'Pending', value: counts.request, color: '#4318FF' },
      { label: 'In Process', value: counts.inProcess, color: '#FFB547' },
      { label: 'Approved', value: counts.approved, color: '#05CD99' },
      { label: 'Received', value: counts.received, color: '#7582eb' },
      { label: 'Downloaded', value: counts.downloaded, color: '#A3AED0' },
    ];
  }, [requests]);

  // I-filter ang 'Request' status para sa priority list
  const pendingRequests = requests.filter(r => r.status === 'Request').slice(0, 5);

  return (
    <Box> {/* Content ra gyud ni, wala na'y Drawer dinhi */}
      
      {/* 1. TOP BAR / HEADER */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 4 }}>
        <Box>
          <Typography variant="h4" fontWeight="800" color="#1B254B">Administrative Overview</Typography>
          <Typography color="text.secondary">
            {loading ? "Updating data..." : "Welcome back, Registrar. Here's what needs your attention."}
          </Typography>
        </Box>

      </Box>

      {/* 2. STATS ROW */}
      <Grid container spacing={3} sx={{ mb: 6 }}>
        {dynamicStats.map((stat, i) => (
          <Grid item xs={12} sm={6} md={2.4} key={i}>
            <Card sx={{ p: 3, borderRadius: 5, boxShadow: '0 4px 20px rgba(0,0,0,0.02)', textAlign: 'center', border: '1px solid #f0f0f0' }}>
              <Typography variant="overline" color="text.secondary" fontWeight="700">{stat.label}</Typography>
              <Typography variant="h4" fontWeight="900" sx={{ my: 1, color: stat.color }}>
                {loading ? <CircularProgress size={20} /> : stat.value}
              </Typography>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* 3. CRITICAL REQUESTS SECTION */}
      <Grid container spacing={4}>
        <Grid item xs={12} width='100%'>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2, width: '100%'}}>
            <Typography variant="h6" fontWeight="800" color="#1B254B">Critical Pending Requests</Typography>
            <Button onClick={() => loadRequests()} size="small" variant="text" sx={{ fontWeight: 'bold' }}>
              Refresh Data
            </Button>
          </Box>

          {error && <Typography color="error" sx={{ mb: 2 }}>{error}</Typography>}

          <Stack spacing={2}>
            {pendingRequests.length > 0 ? (
              pendingRequests.map((req) => (
                <Card key={req.id} sx={{ p: 2.5, borderRadius: 5, display: 'flex', justifyContent: 'space-between', alignItems: 'center', border: '1px solid #f0f0f0', boxShadow: 'none' }}>
                  <Stack direction="row" spacing={3} alignItems="center">
                    <Box sx={{ p: 1.5, bgcolor: '#F4F7FE', borderRadius: 3, color: '#4318FF' }}>
                      <PendingActionsIcon />
                    </Box>
                    <Box>
                      <Typography variant="subtitle1" fontWeight="800" color="#1B254B">
                        {req.documentTypeName || 'Document Request'}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {req.studentName || 'Student Name'} • Ref: {req.referenceNumber}
                      </Typography>
                    </Box>
                  </Stack>
                  
                  <Stack direction="row" spacing={4} alignItems="center">
                    <Box sx={{ textAlign: 'right', minWidth: 100 }}>
                      <Typography variant="caption" fontWeight="bold" color="#A3AED0">STATUS</Typography>
                      <Typography variant="body2" fontWeight="700" color="#4318FF">{req.status}</Typography>
                    </Box>
                    <Stack direction="row" spacing={1}>
                      <IconButton size="small" sx={{ bgcolor: '#F4F7FE' }} title="View Details">
                        <VisibilityIcon fontSize="small"/>
                      </IconButton>
                      <IconButton size="small" sx={{ bgcolor: '#F4F7FE' }} title="Approve Now">
                        <CheckCircleIcon fontSize="small" color="success"/>
                      </IconButton>
                    </Stack>
                  </Stack>
                </Card>
              ))
            ) : (
              <Card sx={{ p: 5, borderRadius: 5, border: '2px dashed #E0E4EC', textAlign: 'center' }}>
                <Typography color="text.secondary">
                  {loading ? "Loading requests..." : "No critical pending requests found."}
                </Typography>
              </Card>
            )}
          </Stack>
        </Grid>
      </Grid>
    </Box>
  );
}