import React, { useEffect, useState, useMemo } from 'react';
import {
  Box, Container, Typography, Grid, Card, Stack, Avatar,
  CircularProgress, Button, Chip, Divider
} from '@mui/material';
import PendingActionsIcon from '@mui/icons-material/PendingActions';
import AutorenewIcon from '@mui/icons-material/Autorenew';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import DescriptionOutlinedIcon from '@mui/icons-material/DescriptionOutlined';
import CampaignOutlinedIcon from '@mui/icons-material/CampaignOutlined';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import { UseAuth } from '../../../context/AuthContext';
import { UseRequests } from '../../../context/RequestContext';
import { useNavigate } from 'react-router-dom';

// ── Design tokens (matches web admin palette) ──────────────────
const NAVY = '#1A237E';
const SLATE = '#64748B';
const DARK = '#1B254B';

function StatCard({ icon, label, value, color, loading }) {
  return (
    <Card elevation={0} sx={{
      p: 3, borderRadius: '20px', border: '1px solid #f0f0f0',
      transition: '0.3s', '&:hover': { boxShadow: '0 12px 30px rgba(0,0,0,0.06)' }
    }}>
      <Stack direction="row" spacing={2} alignItems="center">
        <Box sx={{ p: 1.5, bgcolor: `${color}14`, borderRadius: '12px', display: 'flex' }}>
          {React.cloneElement(icon, { sx: { color, fontSize: 24 } })}
        </Box>
        <Box>
          <Typography variant="h4" fontWeight={900} color={DARK}>
            {loading ? <CircularProgress size={20} /> : value}
          </Typography>
          <Typography variant="caption" fontWeight={700} color={SLATE} sx={{ textTransform: 'uppercase', letterSpacing: 0.8 }}>
            {label}
          </Typography>
        </Box>
      </Stack>
    </Card>
  );
}

const STATUS_COLORS = {
  Request:   { bg: '#E1F5FE', text: '#01579B' },
  InProcess: { bg: '#FFF3E0', text: '#E65100' },
  Approve:   { bg: '#E8F5E9', text: '#1B5E20' },
  Receive:   { bg: '#F3E5F5', text: '#4A148C' },
  Download:  { bg: '#F4F7FE', text: '#707EAE' },
};

export default function StaffDashboard() {
  const { user } = UseAuth();
  const { requests, loading, loadRequests } = UseRequests();
  const navigate = useNavigate();

  useEffect(() => { loadRequests(); }, [loadRequests]);

  const stats = useMemo(() => ({
    pending:    requests.filter(r => r.status === 'Request').length,
    processing: requests.filter(r => r.status === 'InProcess').length,
    approved:   requests.filter(r => r.status === 'Approve' || r.status === 'Receive').length,
    completed:  requests.filter(r => r.status === 'Download').length,
  }), [requests]);

  // Show only active (non-completed) requests, latest 5
  const activeRequests = useMemo(() =>
    requests
      .filter(r => r.status !== 'Download')
      .slice(0, 5),
    [requests]
  );

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: '#F4F7FE' }}>
      <Container maxWidth="lg" sx={{ py: 5 }}>

        {/* Header */}
        <Stack direction="row" justifyContent="space-between" alignItems="flex-start" sx={{ mb: 5 }}>
          <Box>
            <Typography variant="overline" sx={{ color: SLATE, fontWeight: 800, letterSpacing: 1.5 }}>
              STAFF PORTAL
            </Typography>
            <Typography variant="h4" fontWeight={900} color={DARK}>
              Welcome back, {user?.firstName} {user?.lastName}
            </Typography>
            <Typography color={SLATE}>
              {user?.department ?? 'Registrar Office'} · Manage and process student document requests.
            </Typography>
          </Box>
          <Avatar sx={{ width: 52, height: 52, bgcolor: NAVY, fontWeight: 900, fontSize: 20 }}>
            {user?.firstName?.charAt(0).toUpperCase()}
          </Avatar>
        </Stack>

        {/* Stats Row */}
        <Grid container spacing={3} sx={{ mb: 5 }}>
          {[
            { icon: <PendingActionsIcon />, label: 'Pending',    value: stats.pending,    color: '#F59E0B' },
            { icon: <AutorenewIcon />,      label: 'Processing', value: stats.processing, color: '#3B82F6' },
            { icon: <CheckCircleOutlineIcon />, label: 'Approved', value: stats.approved, color: '#10B981' },
            { icon: <DescriptionOutlinedIcon />, label: 'Completed', value: stats.completed, color: '#8B5CF6' },
          ].map((s) => (
            <Grid item xs={6} md={3} key={s.label}>
              <StatCard {...s} loading={loading} />
            </Grid>
          ))}
        </Grid>

        {/* Quick Actions */}
        <Grid container spacing={3} sx={{ mb: 5 }}>
          {[
            {
              icon: <PendingActionsIcon sx={{ fontSize: 28, color: '#3B82F6' }} />,
              title: 'Review Requests',
              desc: 'Process and update student document requests.',
              color: '#3B82F6',
              action: () => navigate('/admin/pending'),
            },
            {
              icon: <CampaignOutlinedIcon sx={{ fontSize: 28, color: '#8B5CF6' }} />,
              title: 'Announcements',
              desc: 'View latest announcements from the registrar.',
              color: '#8B5CF6',
              action: () => navigate('/announcements'),
            },
          ].map((item) => (
            <Grid item xs={12} sm={6} key={item.title}>
              <Card elevation={0} sx={{
                p: 3, borderRadius: '20px', border: '1px solid #f0f0f0', cursor: 'pointer',
                transition: '0.3s', '&:hover': { boxShadow: '0 12px 30px rgba(0,0,0,0.06)', transform: 'translateY(-2px)' }
              }} onClick={item.action}>
                <Stack direction="row" spacing={2} alignItems="center">
                  <Box sx={{ p: 1.5, bgcolor: `${item.color}14`, borderRadius: '12px', display: 'flex' }}>
                    {item.icon}
                  </Box>
                  <Box sx={{ flex: 1 }}>
                    <Typography fontWeight={800} color={DARK}>{item.title}</Typography>
                    <Typography variant="body2" color={SLATE}>{item.desc}</Typography>
                  </Box>
                  <ArrowForwardIcon sx={{ color: '#CBD5E1' }} />
                </Stack>
              </Card>
            </Grid>
          ))}
        </Grid>

        {/* Active Requests */}
        <Card elevation={0} sx={{ borderRadius: '24px', border: '1px solid #f0f0f0', overflow: 'hidden' }}>
          <Stack direction="row" justifyContent="space-between" alignItems="center" sx={{ p: 3, pb: 2 }}>
            <Typography variant="h6" fontWeight={800} color={DARK}>Active Requests</Typography>
            <Button
              size="small" endIcon={<ArrowForwardIcon />}
              onClick={() => navigate('/admin/pending')}
              sx={{ textTransform: 'none', fontWeight: 700, color: NAVY }}
            >
              View All
            </Button>
          </Stack>
          <Divider />

          {/* Table header */}
          <Box sx={{ display: 'flex', px: 3, py: 1.5, bgcolor: '#fbfcfd' }}>
            {['STUDENT', 'DOCUMENT', 'DATE', 'STATUS'].map((h) => (
              <Typography key={h} variant="caption" fontWeight={800} color={SLATE}
                sx={{ flex: h === 'DOCUMENT' ? 2 : 1 }}>
                {h}
              </Typography>
            ))}
          </Box>
          <Divider />

          {loading ? (
            <Box sx={{ p: 5, textAlign: 'center' }}><CircularProgress /></Box>
          ) : activeRequests.length === 0 ? (
            <Box sx={{ p: 5, textAlign: 'center' }}>
              <Typography color={SLATE}>No active requests.</Typography>
            </Box>
          ) : (
            activeRequests.map((req) => {
              const sc = STATUS_COLORS[req.status] ?? STATUS_COLORS.Request;
              return (
                <Box key={req.id} sx={{
                  display: 'flex', alignItems: 'center', px: 3, py: 2,
                  borderBottom: '1px solid #f8f8f8',
                  '&:last-child': { borderBottom: 'none' },
                  '&:hover': { bgcolor: '#fafbff' }
                }}>
                  <Stack direction="row" spacing={1.5} alignItems="center" sx={{ flex: 1 }}>
                    <Avatar sx={{ width: 32, height: 32, bgcolor: `${NAVY}14`, color: NAVY, fontSize: 13, fontWeight: 800 }}>
                      {req.userName?.charAt(0).toUpperCase()}
                    </Avatar>
                    <Typography variant="body2" fontWeight={700} color={DARK} noWrap>
                      {req.userName}
                    </Typography>
                  </Stack>
                  <Typography variant="body2" fontWeight={600} color={DARK} sx={{ flex: 2 }} noWrap>
                    {req.documentTypeName}
                  </Typography>
                  <Typography variant="body2" color={SLATE} sx={{ flex: 1 }}>
                    {new Date(req.requestDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                  </Typography>
                  <Box sx={{ flex: 1 }}>
                    <Chip label={req.status} size="small"
                      sx={{ bgcolor: sc.bg, color: sc.text, fontWeight: 800, fontSize: '0.7rem', borderRadius: '8px' }} />
                  </Box>
                </Box>
              );
            })
          )}
        </Card>

      </Container>
    </Box>
  );
}
