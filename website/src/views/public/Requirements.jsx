import React from 'react';
import { 
  Box, Typography, Container, Grid, Card, 
  CardContent, Stack, Divider, List, ListItem, 
  ListItemIcon, ListItemText, Paper, CircularProgress 
} from '@mui/material';

// Icons
import AssignmentIcon from '@mui/icons-material/Assignment';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import InfoIcon from '@mui/icons-material/Info';

// Context
import { UseMeta } from '../../context/MetaContext'; 

const Requirements = () => {
  const { documentTypes, requirements, loading } = UseMeta();

  return (
    <Box sx={{ bgcolor: '#F0F2F5', minHeight: '100vh', pb: 10 }}>
      {/* Header Section */}
      <Box sx={{ 
        background: 'linear-gradient(135deg, #1A237E 0%, #311B92 100%)', 
        color: 'white', 
        py: { xs: 8, md: 12 }, 
        textAlign: 'center',
        mb: 6,
        clipPath: 'ellipse(150% 100% at 50% 0%)'
      }}>
        <Container maxWidth="md">
          <Typography variant="overline" sx={{ letterSpacing: 3, fontWeight: 800, opacity: 0.8 }}>
            Registrack Guidelines
          </Typography>
          <Typography variant="h2" sx={{ fontWeight: 900, mb: 2, fontSize: { xs: '2.5rem', md: '3.75rem' } }}>
            Document Requirements
          </Typography>
        </Container>
      </Box>

      <Container maxWidth="lg">
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}>
            <CircularProgress sx={{ color: '#1A237E' }} />
          </Box>
        ) : (
          <Grid container spacing={4} justifyContent="center">
            {documentTypes.map((type) => {
           
              const typeRequirements = requirements.filter(req => req.documentTypeId === type.id);

              return (
                <Grid item xs={12} md={4} key={type.id}>
                  <Card sx={{ 
                    height: '100%', 
                    borderRadius: 5, 
                    border: '1px solid rgba(0,0,0,0.05)',
                    width: '560px',
                    background: 'white',
                    transition: '0.3s',
                    '&:hover': { transform: 'translateY(-10px)', boxShadow: '0 20px 40px rgba(26,35,126,0.1)' }
                  }}>
                    <CardContent sx={{ p: 4 }}>
                      <Box sx={{ mb: 3, bgcolor: 'rgba(26, 35, 126, 0.05)', width: 'fit-content', p: 1.5, borderRadius: 3 }}>
                        <AssignmentIcon sx={{ fontSize: 32, color: '#1A237E' }} />
                      </Box>
                      
                      <Typography variant="h5" sx={{ fontWeight: 800, mb: 1, color: '#1A237E' }}>
                        {type.name || type.typeName}
                      </Typography>
                      
                      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                        Listahan sa mga kinahanglanon alang niini nga request.
                      </Typography>
                      
                      <Divider sx={{ mb: 3 }} />
                      
                      <List disablePadding>
                        {typeRequirements.length > 0 ? (
                          typeRequirements.map((req) => (
                            <ListItem key={req.id} disablePadding sx={{ mb: 1.5 }}>
                              <ListItemIcon sx={{ minWidth: 32 }}>
                                <CheckCircleOutlineIcon sx={{ color: '#4caf50', fontSize: 20 }} />
                              </ListItemIcon>
                              <ListItemText 
                                primary={req.name || req.description} 
                                primaryTypographyProps={{ fontSize: '0.9rem', fontWeight: 500, color: '#2D3748' }} 
                              />
                            </ListItem>
                          ))
                        ) : (
                          // Fallback kung walay requirements sa database
                          <Typography variant="body2" color="text.disabled" sx={{ fontStyle: 'italic' }}>
                            No specific requirements listed.
                          </Typography>
                        )}
                      </List>
                    </CardContent>
                  </Card>
                </Grid>
              );
            })}

          </Grid>
        )}
      </Container>
    </Box>
  );
};

export default Requirements;