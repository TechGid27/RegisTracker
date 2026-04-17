import React, { useState } from 'react';
import { 
  Box, Container, Grid, Button, Dialog, 
  DialogContent, DialogTitle, IconButton, Typography 
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import CloseIcon from '@mui/icons-material/Close';
import AnnouncementForm from '../../../components/announcementForm';
import AnnouncementList from '../../../components/announcementList';

export default function AnnouncementsPage() {
  const [editingAnnouncement, setEditingAnnouncement] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleOpenAdd = () => {
    setEditingAnnouncement(null);
    setIsModalOpen(true);
  };

  const handleEditSelect = (announcement) => {
    setEditingAnnouncement(announcement);
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingAnnouncement(null);
  };

  return (
    <Container maxWidth="lg" sx={{ py: 5 }}>
      <Box sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4" fontWeight="900" color="#1B254B">Announcements</Typography>
          <Typography variant="body2" color="text.secondary">Manage student services updates.</Typography>
        </Box>
        
        <Button 
          variant="contained" 
          startIcon={<AddIcon />}
          onClick={handleOpenAdd}
          sx={{ bgcolor: '#4318FF', borderRadius: '12px', fontWeight: '700', textTransform: 'none' }}
        >
          Post New
        </Button>
      </Box>

      {/* Grid v2 Fix: Wala na'y 'item' prop */}
      <Grid container spacing={4}>
        <Grid size={12}> 
          <AnnouncementList onEdit={handleEditSelect} />
        </Grid>
      </Grid>

      <Dialog 
        open={isModalOpen} 
        onClose={handleCloseModal}
        fullWidth
        maxWidth="sm"
        PaperProps={{ sx: { borderRadius: 5 } }}
      >
        {/* Fix: Gigamitan og component="div" aron malikayan ang h2 nesting error */}
        <DialogTitle component="div" sx={{ m: 0, p: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6" fontWeight="800">
            {editingAnnouncement ? 'Edit Announcement' : 'New Announcement'}
          </Typography>
          <IconButton onClick={handleCloseModal}>
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        
        <DialogContent dividers>
          {/* SIGUROHA NGA NAAY onClear PROP! */}
          <AnnouncementForm 
            initialData={editingAnnouncement} 
            onClear={handleCloseModal} 
          />
        </DialogContent>
      </Dialog>
    </Container>
  );
}