import React, { useEffect, useState, useMemo } from 'react';
import { 
  Typography, Button, Box, Alert, CircularProgress, 
  Stack, Grid, Card, Divider, IconButton, Stepper, Step, StepLabel,
  Collapse, TextField, MenuItem, Paper
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import { UseRequests } from '../../../context/RequestContext';
import { useParams, useNavigate } from 'react-router-dom';

function UpdateRequest({ idFromProp, onClose, isModal }) {
  const { id: idFromUrl } = useParams();
  const navigate = useNavigate();
  const { requests, updateRequestStatus, uploadDocument, loadRequests, loading: contextLoading } = UseRequests();
  
  const activeId = idFromProp || idFromUrl;
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const [selectedStatus, setSelectedStatus] = useState('');
  const [notes, setNotes] = useState('');
  const [selectedFile, setSelectedFile] = useState(null);

  const steps = ['Request', 'InProcess', 'Approve', 'Receive', 'Download'];

  useEffect(() => {
    if (requests.length === 0) loadRequests();
  }, [loadRequests, requests.length]);

  const selectedRequest = useMemo(() => {
    return requests.find(r => String(r.id) === String(activeId));
  }, [requests, activeId]);

  useEffect(() => {
    if (selectedRequest) {
      setSelectedStatus(selectedRequest.status);
      setNotes(selectedRequest.notes || '');
    }
  }, [selectedRequest]);

  const isUploaded = !!(selectedRequest?.documentUrl);

  const availableOptions = useMemo(() => {
    if (!selectedRequest) return [];
    const currentIndex = steps.indexOf(selectedRequest.status);
    return steps.filter((step, index) => index === currentIndex || index === currentIndex + 1);
  }, [selectedRequest]);

  const handleFileChange = (e) => {
    setSelectedFile(e.target.files[0]);
    setError('');
  };

  const handleFullUpdate = async () => {
    setLoading(true);
    setError('');
    setSuccess('');

    if (['Approve', 'Download'].includes(selectedStatus) && !isUploaded && !selectedFile) {
      setError("Required: Palihog upload og document.");
      setLoading(false);
      return;
    }

    try {
      if (selectedFile) {
        const uploadSuccess = await uploadDocument(activeId, selectedFile);
        if (!uploadSuccess) throw new Error("Failed to upload file.");
      }

      await updateRequestStatus(activeId, { 
        status: selectedStatus, 
        notes: notes 
      });

      setSuccess("Process updated successfully!");
      setSelectedFile(null);
      await loadRequests();

      if (isModal) {
        setTimeout(() => onClose(), 1500);
      }
    } catch (err) {
      setError(err.message || "Server Error.");
    } finally {
      setLoading(false);
    }
  };

  if (contextLoading && requests.length === 0) return <Box sx={{ p: 5, textAlign: 'center' }}><CircularProgress /></Box>;
  if (!selectedRequest) return <Typography sx={{ p: 3 }}>Request not found.</Typography>;

  return (
    <Box sx={{ p: isModal ? 1 : 4, maxWidth: '1200px', mx: 'auto' }}>
      {!isModal && (
        <IconButton onClick={() => navigate(-1)} sx={{ mb: 2, bgcolor: 'white', boxShadow: 1 }}>
          <ArrowBackIcon />
        </IconButton>
      )}

      <Collapse in={!!error}><Alert severity="error" sx={{ mb: 3, borderRadius: '12px' }}>{error}</Alert></Collapse>
      <Collapse in={!!success}><Alert severity="success" sx={{ mb: 3, borderRadius: '12px' }}>{success}</Alert></Collapse>

      <Grid container spacing={3}>

        <Grid item xs={12}>
            <Grid container spacing={3}>
            
            {/* LEFT COLUMN: 30% (md={4}) */}
            <Grid container size={7} spacing={2}>

                 <Paper elevation={0} sx={{ p: 4, borderRadius: '24px', border: '1px solid #E0E5F2', width: '100%' }}>
                    <Stepper activeStep={steps.indexOf(selectedRequest.status)} alternativeLabel>
                        {steps.map((label) => (
                        <Step key={label}><StepLabel>{label}</StepLabel></Step>
                        ))}
                    </Stepper>
                </Paper>

                <Stack spacing={3} width="100%">
                <Card sx={{ p: 3, borderRadius: '24px', border: '1px solid #E0E5F2', boxShadow: 'none' }}>
                    <Typography variant="subtitle1" fontWeight="800" color="#1B254B" mb={3}>Request Details</Typography>
                    <Stack spacing={2.5}>
                    <Box>
                        <Typography variant="caption" color="#707EAE" fontWeight="800">STUDENT</Typography>
                        <Typography variant="body2" fontWeight="700">{selectedRequest.userName}</Typography>
                    </Box>
                    <Box>
                        <Typography variant="caption" color="#707EAE" fontWeight="800">DOCUMENT</Typography>
                        <Typography variant="body2" fontWeight="700" color="#4318FF">{selectedRequest.documentTypeName}</Typography>
                    </Box>
                    <Divider />
                    <Box>
                        <Typography variant="caption" color="#707EAE" fontWeight="800">PURPOSE</Typography>
                        <Typography variant="body2" sx={{ mt: 0.5 }}>{selectedRequest.purpose || 'N/A'}</Typography>
                    </Box>
                    </Stack>
                </Card>

                <Card sx={{ p: 3, borderRadius: '24px', border: '1px solid #E0E5F2', boxShadow: 'none', bgcolor: '#F4F7FE' }}>
                    <Typography variant="subtitle1" fontWeight="800" color="#1B254B" mb={2}>Attachment</Typography>
                    {isUploaded ? (
                    <Stack spacing={2}>
                        <Box sx={{ p: 1.5, bgcolor: 'white', borderRadius: '12px', border: '1px solid #E0E5F2', display: 'flex', alignItems: 'center', gap: 1 }}>
                        <CheckCircleIcon color="success" sx={{ fontSize: 18 }} />
                        <Typography variant="caption" fontWeight="700" noWrap>{selectedRequest.documentUrl.split('/').pop()}</Typography>
                        </Box>
                        <Button 
                        variant="contained" fullWidth size="small" startIcon={<FileDownloadIcon />}
                        href={`http://localhost:5097${selectedRequest.documentUrl}`} target="_blank"
                        sx={{ borderRadius: '10px', bgcolor: '#1B254B', textTransform: 'none' }}
                        >
                        Download File
                        </Button>
                    </Stack>
                    ) : (
                    <Typography variant="caption" color="text.secondary">No document uploaded.</Typography>
                    )}
                </Card>
                </Stack>
            </Grid>

            {/* RIGHT COLUMN: 70% (md={8}) - KANI ANG FORM NGA DAPAT NAA SA TUO */}
            <Grid item size={5}>
                <Card sx={{ p: 4, borderRadius: '24px', height: '100%', border: '2px solid #4318FF', bgcolor: 'white', boxShadow: '0px 20px 40px rgba(0, 0, 0, 0.05)' }}>
                <Typography variant="h6" fontWeight="800" color="#1B254B" mb={4}>Update Process & Finalize</Typography>
                <Stack spacing={4} width="100%">
                    <Grid container spacing={2}>
                    <Grid item size={12}>
                        <TextField select label="Next Step" fullWidth value={selectedStatus} onChange={(e) => setSelectedStatus(e.target.value)} sx={{ '& .MuiOutlinedInput-root': { borderRadius: '16px' } }}>
                        {availableOptions.map((option) => (<MenuItem key={option} value={option}>{option}</MenuItem>))}
                        </TextField>
                    </Grid>
                    <Grid item size={12}>
                        <TextField label="Internal Remarks" fullWidth value={notes} onChange={(e) => setNotes(e.target.value)} sx={{ '& .MuiOutlinedInput-root': { borderRadius: '16px' } }} />
                    </Grid>
                    </Grid>

                    <TextField label="Detailed Update Description" multiline rows={6} fullWidth value={notes} onChange={(e) => setNotes(e.target.value)} sx={{ '& .MuiOutlinedInput-root': { borderRadius: '20px' } }} />

                    <Box sx={{ p: 3, border: '2px dashed #E0E5F2', borderRadius: '20px', textAlign: 'center' }}>
                    <Typography variant="body2" fontWeight="700" color="#707EAE" mb={2}>{isUploaded ? "REPLACE DOCUMENT" : "UPLOAD DOCUMENT"}</Typography>
                    <Button variant="outlined" component="label" startIcon={<CloudUploadIcon />} sx={{ borderRadius: '12px', px: 4, py: 1.5, borderStyle: 'dashed' }}>
                        {selectedFile ? selectedFile.name : "Choose File"}
                        <input type="file" hidden onChange={handleFileChange} />
                    </Button>
                    </Box>

                    <Button variant="contained" fullWidth onClick={handleFullUpdate} disabled={loading} sx={{ bgcolor: '#4318FF', borderRadius: '16px', py: 2, fontWeight: '800', fontSize: '0.875rem', '&:hover': { bgcolor: '#3311CC' } }}>
                    {loading ? <CircularProgress size={26} color="inherit" /> : "Confirm and Update Status"}
                    </Button>
                </Stack>
                </Card>
            </Grid>

            </Grid> {/* End of nested Grid container */}
        </Grid>

       </Grid>
    </Box>
  );
}

export default UpdateRequest;