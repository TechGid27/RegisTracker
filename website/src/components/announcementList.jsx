import React, { useState } from 'react';
import { 
  Box, Card, Typography, Stack, IconButton, Chip, 
  CircularProgress, Alert, Button, Dialog,
  DialogActions, DialogContent, DialogContentText, DialogTitle,
} from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import CalendarTodayIcon from '@mui/icons-material/CalendarToday';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ExpandLessIcon from '@mui/icons-material/ExpandLess';
import { UseAnnouncements } from '../context/AnnouncementsContext';
import { AnnouncementService } from '../api/AnnoucementService';

export default function AnnouncementList({ onEdit }) {
  const { announcements, loading, error, refreshMetadata } = UseAnnouncements();
  const [deleting, setDeleting] = useState(false);
  const [openDialog, setOpenDialog] = useState(false);
  const [selectedId, setSelectedId] = useState(null);
  
  // State para sa "See More" matag card
  const [expandedIds, setExpandedIds] = useState({});

  const toggleExpand = (id) => {
    setExpandedIds(prev => ({
      ...prev,
      [id]: !prev[id]
    }));
  };

  const handleDelete = async () => {
    setDeleting(true);
    try {
      await AnnouncementService.delete(selectedId);
      await refreshMetadata();
      setOpenDialog(false);
    } catch (err) {
      alert("Failed to delete: " + err.message);
    } finally {
      setDeleting(false);
    }
  };

  if (loading && announcements.length === 0) return <CircularProgress sx={{ display: 'block', mx: 'auto', mt: 5 }} />;
  if (error) return <Alert severity="error">{error}</Alert>;

  return (
    <Box sx={{ mt: 4 }}>
      <Typography variant="h6" fontWeight="800" color="#1B254B" mb={2}>
        Recent Announcements
      </Typography>
      
      <Stack spacing={2.5}>
        {announcements.map((ann) => {
          const isExpanded = expandedIds[ann.id];
          const isLongContent = ann.content.length > 150;
          const displayContent = isLongContent && !isExpanded 
            ? `${ann.content.substring(0, 150)}...` 
            : ann.content;

          return (
            <Card key={ann.id} sx={{ 
              p: 3, 
              borderRadius: 5, 
              boxShadow: '0 10px 30px rgba(163, 174, 208, 0.08)', 
              border: '1px solid #F4F7FE',
              transition: '0.3s',
              '&:hover': { boxShadow: '0 15px 35px rgba(163, 174, 208, 0.15)' }
            }}>
              <Stack direction="row" justifyContent="space-between" alignItems="flex-start">
                <Box sx={{ width: '85%' }}>
                  <Stack direction="row" spacing={1} alignItems="center" mb={1.5}>
                    <Chip 
                      label={ann.priority} 
                      size="small" 
                      color={ann.priority === 'High' || ann.priority === 'Urgent' ? 'error' : 'primary'}
                      sx={{ fontWeight: 700, borderRadius: 2, fontSize: '0.65rem' }}
                    />
                    <Typography variant="caption" color="#A3AED0" display="flex" alignItems="center" fontWeight="600">
                      <CalendarTodayIcon sx={{ fontSize: 14, mr: 0.5 }} />
                      Expires: {ann.expiryDate ? new Date(ann.expiryDate).toLocaleDateString() : 'No Expiry'}
                    </Typography>
                  </Stack>
                  
                  <Typography variant="h6" fontWeight="800" color="#1B254B" sx={{ lineHeight: 1.3 }}>
                    {ann.title}
                  </Typography>

                  <Box sx={{ mt: 1.5 }}>
                    <Typography variant="body2" color="#47548C" sx={{ 
                      whiteSpace: 'pre-line', 
                      lineHeight: 1.6,
                      fontSize: '0.9rem' 
                    }}>
                      {displayContent}
                    </Typography>
                    
                    {isLongContent && (
                      <Button 
                        size="small" 
                        onClick={() => toggleExpand(ann.id)}
                        startIcon={isExpanded ? <ExpandLessIcon /> : <ExpandMoreIcon />}
                        sx={{ 
                          mt: 0.5, 
                          textTransform: 'none', 
                          fontWeight: '700', 
                          color: '#4318FF',
                          '&:hover': { bgcolor: 'transparent', textDecoration: 'underline' }
                        }}
                      >
                        {isExpanded ? 'Show Less' : 'Read More'}
                      </Button>
                    )}
                  </Box>
                </Box>

                <Stack direction="row" spacing={1}>
                  <IconButton 
                    onClick={() => onEdit(ann)} 
                    sx={{ color: '#4318FF', bgcolor: '#F4F7FE', borderRadius: 3 }}
                  >
                    <EditIcon fontSize="small" />
                  </IconButton>
                  <IconButton 
                    onClick={() => { setSelectedId(ann.id); setOpenDialog(true); }}
                    sx={{ color: '#FF5B5B', bgcolor: '#FFF5F5', borderRadius: 3 }}
                  >
                    <DeleteIcon fontSize="small" />
                  </IconButton>
                </Stack>
              </Stack>
            </Card>
          );
        })}
      </Stack>

      {/* Dialog remains the same... */}
      <Dialog 
        open={openDialog} 
        onClose={() => setOpenDialog(false)}
        PaperProps={{ sx: { borderRadius: 4, p: 1 } }}
      >
        <DialogTitle sx={{ fontWeight: 800 }}>Confirm Delete</DialogTitle>
        <DialogContent>
          <DialogContentText color="#47548C">
            Are you sure you want to remove this announcement? This action cannot be undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button onClick={() => setOpenDialog(false)} sx={{ fontWeight: 700, color: '#A3AED0' }}>Cancel</Button>
          <Button 
            onClick={handleDelete} 
            color="error" 
            variant="contained" 
            disabled={deleting}
            sx={{ borderRadius: 3, px: 3, fontWeight: 700, bgcolor: '#EE5D50' }}
          >
            {deleting ? 'Deleting...' : 'Delete Now'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}