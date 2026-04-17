import { useState, useEffect } from 'react';
import { 
  Box, Card, Typography, TextField, Stack, Button, 
  MenuItem, Alert, CircularProgress, InputAdornment, Collapse 
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import UpdateIcon from '@mui/icons-material/Update';
import DescriptionIcon from '@mui/icons-material/Description';
import TitleIcon from '@mui/icons-material/Title';
import EventIcon from '@mui/icons-material/Event';
import PriorityHighIcon from '@mui/icons-material/PriorityHigh';
import { UseAnnouncements } from '../context/AnnouncementsContext'; 
import { AnnouncementService } from '../api/AnnoucementService';

export default function AnnouncementForm({ initialData, onClear = () => {} }) {
  const { refreshMetadata } = UseAnnouncements(); 
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);

  const [fieldErrors, setFieldErrors] = useState({});
  const [apiError, setApiError] = useState(null);

  const [formData, setFormData] = useState({
    title: '',
    content: '',
    priority: 'Normal',
    createdBy: 8, 
    expiryDate: ''
  });

  useEffect(() => {
    if (initialData) {
      setFormData({
        title: initialData.title || '',
        content: initialData.content || '',
        priority: initialData.priority || 'Normal',
        createdBy: initialData.createdBy || 8,
        expiryDate: initialData.expiryDate ? initialData.expiryDate.split('T')[0] : ''
      });
      setSuccess(false);
      setFieldErrors({});
      setApiError(null);
    }
  }, [initialData]);

  // I-clear ang error sa usa ka field inig sugod og type sa user
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (fieldErrors[name]) {
      setFieldErrors(prev => ({ ...prev, [name]: null }));
    }
  };

  const validateForm = () => {
    let errors = {};
    if (!formData.title.trim()) errors.title = "Headline is required.";
    if (!formData.content.trim()) errors.content = "Detailed content is required.";
    if (formData.content.trim().length < 10) errors.content = "Content must be at least 10 characters.";
    
    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSuccess(false);
    setApiError(null);

    // Diri i-check kon naay kulang sa fields
    if (!validateForm()) return;

    setSubmitting(true);
    const loggedInUser = JSON.parse(localStorage.getItem('user'));
    const currentAdminId = loggedInUser?.id || 8;

    const payload = {
      title: formData.title.trim(),
      content: formData.content.trim(),
      priority: formData.priority, 
      createdBy: initialData ? initialData.createdBy : Number(currentAdminId),
      expiryDate: formData.expiryDate ? new Date(formData.expiryDate).toISOString() : null
    };

    try {
      if (initialData?.id) {
        await AnnouncementService.update(initialData.id, payload);
      } else {
        await AnnouncementService.create(payload);
      }
      
      await refreshMetadata(); 
      setSuccess(true);

      // Clear form after success if not editing
      if (!initialData) {
        setFormData({ title: '', content: '', priority: 'Normal', expiryDate: '' });
      }

      setTimeout(() => {
        onClear();
        setSuccess(false);
      }, 2000);

    } catch (err) {
      setApiError(err.message || "Something went wrong on the server.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Card sx={{ borderRadius: 6, boxShadow: '0 20px 40px rgba(163, 174, 208, 0.08)', border: '1px solid #F4F7FE', background: '#fff' }}>
      <Box sx={{ p: 4, pb: 0 }}>
        <Typography variant="h5" fontWeight="900" color="#1B254B">
          {initialData ? 'Update Information' : 'New Announcement'}
        </Typography>
        <Typography variant="body2" color="#A3AED0" sx={{ mt: 0.5 }}>
          Fill out the details below to broadcast information to the campus.
        </Typography>
      </Box>

      <Box component="form" onSubmit={handleSubmit} sx={{ p: 4 }}>
        <Stack spacing={3.5}>
          
          {/* MESSAGES */}
          <Stack spacing={1}>
            <Collapse in={success}>
              <Alert severity="success" sx={{ borderRadius: 3, fontWeight: 600 }}>
                Successfully saved to Registrack!
              </Alert>
            </Collapse>
            
            <Collapse in={!!apiError}>
              <Alert severity="error" sx={{ borderRadius: 3 }}>
                {apiError}
              </Alert>
            </Collapse>
          </Stack>


          {/* TITLE FIELD */}
          <TextField
            fullWidth label="Headline" name="title"
            value={formData.title} onChange={handleChange}
            placeholder="e.g. Enrollment is now open"
            error={!!fieldErrors.title} // Mahimong pula kon naay error
            helperText={fieldErrors.title || "Keep it short and impactful."} // Ang error text mogawas diri
            InputProps={{ 
              sx: { borderRadius: 3, bgcolor: '#F8FAFF' },
              startAdornment: (
                <InputAdornment position="start">
                  <TitleIcon sx={{ color: fieldErrors.title ? '#d32f2f' : '#4318FF', fontSize: 20 }} />
                </InputAdornment>
              ),
            }}
          />

          <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2.5}>
            {/* PRIORITY FIELD */}
            <TextField
              select fullWidth label="Level of Priority" name="priority"
              value={formData.priority} onChange={handleChange}
              InputProps={{ 
                sx: { borderRadius: 3, bgcolor: '#F8FAFF' },
                startAdornment: (
                  <InputAdornment position="start">
                    <PriorityHighIcon sx={{ color: '#4318FF', fontSize: 20 }} />
                  </InputAdornment>
                ),
              }}
            >
              {['Low', 'Normal', 'High', 'Urgent'].map(p => (
                <MenuItem key={p} value={p} sx={{ fontWeight: 600 }}>{p}</MenuItem>
              ))}
            </TextField>

            {/* DATE FIELD */}
            <TextField
              fullWidth label="Show Until" type="date" name="expiryDate"
              value={formData.expiryDate} onChange={handleChange}
              helperText="Optional expiry date."
              InputLabelProps={{ shrink: true }}
              InputProps={{ 
                sx: { borderRadius: 3, bgcolor: '#F8FAFF' },
                startAdornment: (
                  <InputAdornment position="start">
                    <EventIcon sx={{ color: '#4318FF', fontSize: 20 }} />
                  </InputAdornment>
                ),
              }}
            />
          </Stack>

          {/* CONTENT FIELD */}
          <TextField
            fullWidth multiline rows={5} label="Detailed Content" name="content"
            value={formData.content} onChange={handleChange}
            placeholder="Provide context here..."
            error={!!fieldErrors.content} // Mahimong pula kon naay error
            helperText={fieldErrors.content || "Instructions or details."}
            InputProps={{ 
              sx: { borderRadius: 3, bgcolor: '#F8FAFF' },
              startAdornment: (
                <InputAdornment position="start" sx={{ alignSelf: 'flex-start', mt: 1.5 }}>
                  <DescriptionIcon sx={{ color: fieldErrors.content ? '#d32f2f' : '#4318FF', fontSize: 20 }} />
                </InputAdornment>
              ),
            }}
          />


          <Button 
            fullWidth type="submit" disabled={submitting} variant="contained" 
            endIcon={submitting ? <CircularProgress size={20} color="inherit" /> : (initialData ? <UpdateIcon /> : <SendIcon />)}
            sx={{ 
              py: 2, borderRadius: 4, bgcolor: '#4318FF', fontWeight: '900',
              textTransform: 'none', boxShadow: '0 10px 25px rgba(67, 24, 255, 0.25)',
              '&:hover': { bgcolor: '#3311CC', transform: 'translateY(-2px)' },
              transition: '0.3s'
            }}
          >
            {submitting ? 'Processing...' : (initialData ? 'Update Record' : 'Publish Announcement')}
          </Button>
        </Stack>
      </Box>
    </Card>
  );
}