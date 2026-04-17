import React, { useState } from 'react';
import {
  Box, Container, Typography, Button, Grid, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, TextField,
  Stack, InputAdornment, Card, CardContent, Divider, CircularProgress,
  FormControlLabel, Switch, Collapse, Alert
} from '@mui/material';
import { Formik, FastField } from 'formik';
import * as Yup from 'yup';

// Icons
import AddRoundedIcon from '@mui/icons-material/AddRounded';
import EditTwoToneIcon from '@mui/icons-material/EditTwoTone';
import DeleteTwoToneIcon from '@mui/icons-material/DeleteTwoTone';
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import PaymentsIcon from '@mui/icons-material/Payments';
import DescriptionTwoToneIcon from '@mui/icons-material/DescriptionTwoTone';
import DriveFileRenameOutlineIcon from '@mui/icons-material/DriveFileRenameOutline';

import { UseDocumentTypes } from '../../../context/DocumentTypeContext';

// ✅ Validation Schema based on your requirements
const validationSchema = Yup.object({
  name: Yup.string().required('Document name is required'),
  description: Yup.string().required('Description is required').min(5, 'Description too short'),
  processingFee: Yup.number().min(0, 'Fee cannot be negative').required('Required'),
  processingDays: Yup.number().min(1, 'Minimum 1 day').required('Required'),
});

// ✅ Memoized Input Component to stop [Violation] lag
const FormInput = React.memo(({ name, label, type = "text", multiline = false, rows = 1, startIcon, endAdornment }) => {
  return (
    <FastField name={name}>
      {({ field, meta }) => (
        <TextField
          {...field}
          fullWidth
          label={label}
          type={type}
          multiline={multiline}
          rows={rows}
          error={meta.touched && Boolean(meta.error)}
          helperText={meta.touched ? meta.error : ""}
          InputProps={{
            sx: { borderRadius: 3, bgcolor: '#F8FAFF' },
            startAdornment: startIcon ? (
              <InputAdornment position="start">{startIcon}</InputAdornment>
            ) : null,
            endAdornment: endAdornment,
          }}
        />
      )}
    </FastField>
  );
});

function DocumentTypePage() {
  const { 
    documentTypes, loading, addDocumentType, 
    updateDocumentType, deleteDocumentType 
  } = UseDocumentTypes();

  const [open, setOpen] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [apiError, setApiError] = useState(null);
  const [initialValues, setInitialValues] = useState({
    name: '', description: '', processingFee: 0, processingDays: 0, isActive: true
  });

  const handleOpen = (doc = null) => {
    setApiError(null);
    if (doc) {
      setEditMode(true);
      setInitialValues(doc);
    } else {
      setEditMode(false);
      setInitialValues({ name: '', description: '', processingFee: 0, processingDays: 0, isActive: true });
    }
    setOpen(true);
  };

  const handleClose = () => setOpen(false);

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: '#F8FAFC', py: 6 }}>
      <Container maxWidth="lg">
        {/* Header */}
        <Stack direction={{ xs: 'column', sm: 'row' }} justifyContent="space-between" alignItems="center" spacing={2} sx={{ mb: 6 }}>
          <Box>
            <Typography variant="h3" fontWeight={900} sx={{ color: '#1E293B', letterSpacing: '-1px', mb: 1 }}>
              Document <span style={{ color: '#1A237E' }}>Types</span>
            </Typography>
            <Typography variant="body1" color="text.secondary" fontWeight={500}>
              Configure your service catalog and processing rules.
            </Typography>
          </Box>
          <Button 
            variant="contained" 
            disableElevation
            startIcon={<AddRoundedIcon />} 
            onClick={() => handleOpen()}
            sx={{ 
              bgcolor: '#1A237E', borderRadius: '12px', textTransform: 'none', px: 4, py: 1.5,
              fontWeight: 700, '&:hover': { bgcolor: '#0D145A' }
            }}
          >
            New Document
          </Button>
        </Stack>

        {loading ? (
          <Box display="flex" justifyContent="center" py={10}><CircularProgress /></Box>
        ) : (
          <Grid container spacing={3} alignItems="stretch">
            {documentTypes.map((doc) => (
              <Grid item xs={12} sm={6} md={4} key={doc.id} sx={{ display: 'flex' }}>
                <Card sx={{ 
                  display: 'flex', 
                  flexDirection: 'column', 
                  justifyContent: 'space-between', 
                  width: '450px',
                  maxwidth: '100%', 
                  borderRadius: '20px', 
                  border: '1px solid rgba(0,0,0,0.05)',
                  transition: 'all 0.3s ease',
                  opacity: doc.isActive ? 1 : 0.6,
                  '&:hover': { transform: 'translateY(-8px)', boxShadow: '0 20px 40px rgba(0,0,0,0.08)' }
                }}>
                  <CardContent sx={{ p: 3, flexGrow: 1 }}>
                    <Stack direction="row" justifyContent="space-between" sx={{ mb: 2 }}>
                      <Box sx={{ bgcolor: 'rgba(26, 35, 126, 0.08)', p: 1.5, borderRadius: '12px' }}>
                        <DescriptionTwoToneIcon sx={{ color: '#1A237E' }} />
                      </Box>
                      <Box>
                        <IconButton onClick={() => handleOpen(doc)} size="small"><EditTwoToneIcon fontSize="small" /></IconButton>
                        <IconButton onClick={() => deleteDocumentType(doc.id)} size="small" sx={{ color: '#EF4444' }}><DeleteTwoToneIcon fontSize="small" /></IconButton>
                      </Box>
                    </Stack>

                    <Typography variant="h6" fontWeight={800} sx={{ mb: 1 }}>{doc.name}</Typography>
                    <Typography variant="body2" sx={{ color: '#64748B', mb: 3, minHeight: '60px' }}>{doc.description}</Typography>
                    
                    <Divider sx={{ mb: 2, borderStyle: 'dashed' }} />

                    <Stack direction="row" justifyContent="space-between">
                      <Stack direction="row" alignItems="center" spacing={1}>
                        <PaymentsIcon sx={{ fontSize: 18, color: '#10B981' }} />
                        <Typography variant="subtitle2" fontWeight={700}>₱{doc.processingFee.toLocaleString()}</Typography>
                      </Stack>
                      <Stack direction="row" alignItems="center" spacing={1}>
                        <AccessTimeIcon sx={{ fontSize: 18, color: '#F59E0B' }} />
                        <Typography variant="subtitle2" fontWeight={700}>{doc.processingDays} Days</Typography>
                      </Stack>
                    </Stack>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        )}

        {/* ✅ Formik Logic Applied to Dialog */}
        <Dialog open={open} onClose={handleClose} fullWidth maxWidth="sm" PaperProps={{ sx: { borderRadius: '24px' } }}>
          <Formik
            initialValues={initialValues}
            validationSchema={validationSchema}
            enableReinitialize // Important for editMode to populate fields
            onSubmit={async (values, { setSubmitting }) => {
              setApiError(null);
              const payload = {
                ...values,
                processingFee: Number(values.processingFee),
                processingDays: Number(values.processingDays),
              };

              const result = editMode 
                ? await updateDocumentType(values.id, payload)
                : await addDocumentType(payload);

              if (result.success) {
                handleClose();
              } else {
                setApiError(result.error || "Failed to save.");
              }
              setSubmitting(false);
            }}
          >
            {({ handleSubmit, isSubmitting, setFieldValue, values }) => (
              <Box component="form" onSubmit={handleSubmit} noValidate>
                <DialogTitle sx={{ fontWeight: 900, pt: 3 }}>
                  {editMode ? 'Update Document' : 'Add New Document'}
                </DialogTitle>
                
                <DialogContent>
                  <Stack spacing={3} sx={{ mt: 1 }}>
                    <Collapse in={!!apiError}>
                      <Alert severity="error" sx={{ borderRadius: 3 }}>{apiError}</Alert>
                    </Collapse>

                    <FormInput 
                      name="name" 
                      label="Document Name" 
                      startIcon={<DriveFileRenameOutlineIcon sx={{ color: '#1A237E', fontSize: 20 }} />}
                    />

                    <FormInput 
                      name="description" 
                      label="Description" 
                      multiline rows={3}
                      startIcon={<DescriptionTwoToneIcon sx={{ color: '#1A237E', fontSize: 20 }} />}
                    />

                    <Stack direction="row" spacing={2}>
                      <FormInput 
                        name="processingFee" 
                        label="Processing Fee" 
                        type="number"
                        startIcon={<Typography fontWeight="bold" color="#1A237E">₱</Typography>}
                      />
                      <FormInput 
                        name="processingDays" 
                        label="Days" 
                        type="number"
                        endAdornment={<InputAdornment position="end">Days</InputAdornment>}
                      />
                    </Stack>

                    <FormControlLabel
                      control={
                        <Switch 
                          checked={values.isActive} 
                          onChange={(e) => setFieldValue('isActive', e.target.checked)}
                          sx={{ '& .MuiSwitch-switchBase.Mui-checked': { color: '#1A237E' } }}
                        />
                      }
                      label="Available for requests"
                    />
                  </Stack>
                </DialogContent>

                <DialogActions sx={{ p: 4, pt: 0 }}>
                  <Button onClick={handleClose} sx={{ color: '#64748B', fontWeight: 700 }}>Discard</Button>
                  <Button 
                    type="submit" 
                    variant="contained" 
                    disabled={isSubmitting}
                    sx={{ 
                      bgcolor: '#1A237E', px: 4, borderRadius: 3, fontWeight: 700,
                      textTransform: 'none', boxShadow: '0 10px 20px rgba(26, 35, 126, 0.2)'
                    }}
                  >
                    {isSubmitting ? <CircularProgress size={24} color="inherit" /> : 'Confirm'}
                  </Button>
                </DialogActions>
              </Box>
            )}
          </Formik>
        </Dialog>
      </Container>
    </Box>
  );
}

export default DocumentTypePage;