import { 
  Box, Typography, Stack, TextField, Button, Container, 
  Card, CardContent, Grid, 
  Accordion, AccordionSummary, AccordionDetails, 
  Collapse, Alert, Dialog, DialogTitle, DialogContent, DialogActions, Chip, CircularProgress 
} from "@mui/material";
import * as React from 'react';
import { UseRequests } from '../../context/RequestContext'; // Siguroha husto ang path

// Icons
import DescriptionIcon from '@mui/icons-material/Description';
import AutorenewIcon from '@mui/icons-material/Autorenew';
import VerifiedUserIcon from '@mui/icons-material/VerifiedUser';
import MarkEmailReadIcon from '@mui/icons-material/MarkEmailRead';
import DownloadDoneIcon from '@mui/icons-material/DownloadDone';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import AssignmentIndIcon from '@mui/icons-material/AssignmentInd';
import ReceiptLongIcon from '@mui/icons-material/ReceiptLong';
import TaskAltIcon from '@mui/icons-material/TaskAlt';

const cards = [
  { id: 1, title: 'Request', icon: <DescriptionIcon sx={{ fontSize: 32 }} />, description: 'Student submits the application form and requirements.' },
  { id: 2, title: 'In Process', icon: <AutorenewIcon sx={{ fontSize: 32 }} />, description: "The Registrar's office is verifying and preparing documents." },
  { id: 3, title: 'Approve', icon: <VerifiedUserIcon sx={{ fontSize: 32 }} />, description: 'Academic heads have signed and approved the release.' },
  { id: 4, title: 'Ready', icon: <MarkEmailReadIcon sx={{ fontSize: 32 }} />, description: 'Document is available for pick-up or digital download.' },
  { id: 5, title: 'Downloaded', icon: <DownloadDoneIcon sx={{ fontSize: 32 }} />, description: 'The process is complete and document has been received.' }
];

function SelectActionCard({ activeStep }) {
  return (
    <Box sx={{ 
      display: 'grid', 
      gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
      gap: 3,
      mt: 4 
    }}>
      {cards.map((card, index) => (
        <Card 
          key={card.id} 
          sx={{ 
            borderRadius: 4,
            transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
            position: 'relative',
            overflow: 'hidden',
            background: activeStep === index ? 'rgba(255, 255, 255, 0.95)' : 'rgba(255, 255, 255, 0.2)',
            backdropFilter: 'blur(10px)',
            border: activeStep === index ? '2px solid #4318FF' : '1px solid rgba(255, 255, 255, 0.3)',
            boxShadow: activeStep === index ? '0 20px 40px rgba(0,0,0,0.15)' : '0 4px 6px rgba(0,0,0,0.02)',
            transform: activeStep === index ? 'translateY(-10px)' : 'none',
          }}
        >
          <CardContent sx={{ p: 3 }}>
            <Box sx={{ 
              display: 'inline-flex',
              p: 1.5, 
              borderRadius: 3, 
              bgcolor: activeStep === index ? '#4318FF' : 'rgba(255,255,255,0.1)',
              color: 'white',
              mb: 2,
            }}>
              {card.icon}
            </Box>
            <Typography variant="h6" fontWeight="800" sx={{ mb: 1, color: activeStep === index ? '#1B254B' : 'white' }}>
              {card.title}
            </Typography>
            <Typography variant="body2" sx={{ color: activeStep === index ? 'text.secondary' : 'rgba(255,255,255,0.7)' }}>
              {card.description}
            </Typography>
          </CardContent>
        </Card>
      ))}
    </Box>
  );
}

export default function Home() {
  const { trackByReference, loading } = UseRequests();
  const [refNumber, setRefNumber] = React.useState("");
  const [activeStep, setActiveStep] = React.useState(-1);
  const [openResult, setOpenResult] = React.useState(false);
  const [error, setError] = React.useState(false);
  const [trackingData, setTrackingData] = React.useState(null);

  const handleTrack = async () => {
    if (!refNumber.trim()) return;
    setError(false);

    try {
      const data = await trackByReference(refNumber);
      if (data) {
        setTrackingData(data);
        const stepIndex = cards.findIndex(c => c.title.toLowerCase() === data.status.toLowerCase());
        setActiveStep(stepIndex);
        setOpenResult(true);
      }
    } catch (err) {
      setError(true);
      setActiveStep(-1);
    }
  };

  return (
    <Box sx={{ bgcolor: '#F0F2F5', minHeight: '100vh' }}>
      {/* Hero Section */}
      <Box sx={{ 
        background: 'radial-gradient(circle at top right, #e3f2fd, transparent), radial-gradient(circle at bottom left, #fff9c4, transparent)',
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center'
      }}>
        <Container maxWidth="lg">
          <Grid container spacing={4} alignItems="center">
            <Grid item xs={12} md={7}>
              <Stack spacing={3}>
                <Typography variant="overline" sx={{ fontWeight: 800, color: 'primary.main', letterSpacing: 2 }}>
                  Academic Transparency System
                </Typography>
                <Typography variant="h1" sx={{ fontWeight: 900, fontSize: { xs: '3rem', md: '4.5rem' }, lineHeight: 1.1 }}>
                  Track Your <br />
                  <span style={{ color: '#1a237e' }}>Documents</span>
                </Typography>

                {/* COLLAPSE ALERT AREA - ANAA SA TAAS/TUNGA */}
                <Box sx={{ maxWidth: 550 }}>
                   <Collapse in={error}>
                    <Alert severity="error" sx={{ borderRadius: 3, mb: 2, fontWeight: 600 }}>
                      Reference number not found. Please double check.
                    </Alert>
                  </Collapse>
                </Box>

                <Typography variant="h6" color="text.secondary" sx={{ fontWeight: 400, maxWidth: 500 }}>
                  A seamless way to monitor your academic requests in real-time.
                </Typography>
                
                <Box sx={{ 
                  display: 'flex', 
                  bgcolor: 'white', 
                  p: 1, 
                  borderRadius: 4, 
                  boxShadow: '0 10px 30px rgba(0,0,0,0.05)',
                  maxWidth: 550 
                }}>
                  <TextField 
                    fullWidth 
                    variant="standard"
                    placeholder="Enter Reference Number..." 
                    value={refNumber}
                    onChange={(e) => setRefNumber(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && handleTrack()}
                    InputProps={{ disableUnderline: true, sx: { px: 2, fontWeight: 500 } }}
                  />
                  <Button 
                    onClick={handleTrack}
                    disabled={loading}
                    variant="contained" 
                    sx={{ px: 4, py: 1.5, borderRadius: 3, fontWeight: 'bold', textTransform: 'none', bgcolor: '#1a237e' }}
                  >
                    {loading ? <CircularProgress size={24} color="inherit" /> : "Track Now"}
                  </Button>
                </Box>
              </Stack>
            </Grid>
          </Grid>
        </Container>
      </Box>

      {/* Tracker Section */}
      <Box sx={{ 
        py: 12, position: 'relative',
        background: 'linear-gradient(135deg, #1a237e 0%, #311b92 100%)',
        borderRadius: { md: '80px 80px 0 0' },
        mt: -10, zIndex: 2, color: 'white'
      }}>
        <Container maxWidth="lg">
          <Stack spacing={1} sx={{ mb: 6 }}>
            <Typography variant="h3" fontWeight="800">Tracker Process</Typography>
            <Typography variant="body1" sx={{ opacity: 0.7 }}>
              {activeStep !== -1 ? `Viewing status for ${refNumber}` : "Follow the journey of your academic papers."}
            </Typography>
          </Stack>
          <SelectActionCard activeStep={activeStep} />
        </Container>
      </Box>

      {/* SUCCESS DIALOG */}
      <Dialog 
        open={openResult} 
        onClose={() => setOpenResult(false)}
        PaperProps={{ sx: { borderRadius: 5, p: 2, minWidth: 380 } }}
      >
        <DialogTitle sx={{ fontWeight: 900, color: '#1a237e', textAlign: 'center', pb: 0 }}>
          Document Located!
        </DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 2 }}>
            <Box sx={{ p: 2, bgcolor: '#EEF2FF', borderRadius: 3, border: '2px dashed #4318FF', textAlign: 'center' }}>
              <Typography variant="caption" color="primary" fontWeight="800">REFERENCE NUMBER</Typography>
              <Typography variant="h6" fontWeight="900" color="#1a237e">{trackingData?.referenceNumber}</Typography>
            </Box>
            <Box sx={{ p: 2, bgcolor: '#F8FAFF', borderRadius: 3, border: '1px solid #E0E4F0' }}>
              <Typography variant="caption" color="text.secondary" fontWeight="700">REQUESTOR</Typography>
              <Typography variant="body1" fontWeight="800">{trackingData?.userName}</Typography>
              <Typography variant="caption" color="text.secondary">{trackingData?.userEmail}</Typography>
            </Box>
            <Grid container spacing={1}>
              <Grid item xs={12}><Box sx={{ p: 2, bgcolor: '#F8FAFF', borderRadius: 3, border: '1px solid #E0E4F0' }}><Typography variant="caption" color="text.secondary" fontWeight="700">DOCUMENT</Typography><Typography variant="body1" fontWeight="700">{trackingData?.documentTypeName}</Typography></Box></Grid>
              <Grid item xs={6}><Box sx={{ p: 2, bgcolor: '#F8FAFF', borderRadius: 3, border: '1px solid #E0E4F0' }}><Typography variant="caption" color="text.secondary" fontWeight="700">QTY</Typography><Typography variant="body1" fontWeight="700">{trackingData?.quantity}</Typography></Box></Grid>
              <Grid item xs={6}><Box sx={{ p: 2, bgcolor: '#F8FAFF', borderRadius: 3, border: '1px solid #E0E4F0' }}><Typography variant="caption" color="text.secondary" fontWeight="700">STATUS</Typography><Chip label={trackingData?.status} size="small" color="success" sx={{ fontWeight: 900 }} /></Box></Grid>
            </Grid>
          </Stack>
        </DialogContent>
        <DialogActions sx={{ p: 3 }}><Button onClick={() => setOpenResult(false)} variant="contained" fullWidth sx={{ borderRadius: 3, bgcolor: '#1a237e' }}>Close Details</Button></DialogActions>
      </Dialog>

      {/* Requirements Section */}
      <Container maxWidth="lg" sx={{ py: 15 }}>
        <Grid container spacing={10} alignItems="center">
          <Grid item xs={12} md={6}>
            <Box sx={{ position: 'relative' }}>
              <Box sx={{ position: 'absolute', top: -20, left: -20, right: 20, bottom: 20, bgcolor: 'primary.main', borderRadius: 8, opacity: 0.1 }} />
              <Box component="img" src="https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&q=80&w=800" sx={{ width: '100%', borderRadius: 8, position: 'relative', boxShadow: '0 30px 60px rgba(0,0,0,0.15)' }} />
            </Box>
          </Grid>
          <Grid item xs={12} md={6}>
            <Typography variant="h3" fontWeight="800" gutterBottom>Requirements</Typography>
            <Stack spacing={4}>
              {[{ title: 'Valid Identification', icon: <AssignmentIndIcon />, color: '#3f51b5' }, { title: 'Clearance Form', icon: <TaskAltIcon />, color: '#4caf50' }].map((item, i) => (
                <Box key={i} sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                  <Box sx={{ p: 2, borderRadius: 4, bgcolor: 'white', color: item.color, boxShadow: '0 10px 20px rgba(0,0,0,0.05)', display: 'flex' }}>{item.icon}</Box>
                  <Typography variant="h6" fontWeight="700">{item.title}</Typography>
                </Box>
              ))}
            </Stack>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}