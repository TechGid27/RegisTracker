import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Container, Typography, Stack, Card, Button, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, TextField,
  MenuItem, CircularProgress, Alert, Collapse, Chip, Divider,
  Accordion, AccordionSummary, AccordionDetails, FormControlLabel, Switch
} from '@mui/material';
import AddRoundedIcon from '@mui/icons-material/AddRounded';
import EditRoundedIcon from '@mui/icons-material/EditRounded';
import DeleteOutlineRoundedIcon from '@mui/icons-material/DeleteOutlineRounded';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import DescriptionOutlinedIcon from '@mui/icons-material/DescriptionOutlined';
import { Formik, FastField } from 'formik';
import * as Yup from 'yup';
import { metaService } from '../../../api/MetaService';

const NAVY = '#1A237E';
const SLATE = '#64748B';
const DARK = '#1B254B';

const schema = Yup.object({
  documentTypeId: Yup.number().required('Document type is required'),
  requirementName: Yup.string().min(3, 'Min 3 characters').required('Required'),
  description: Yup.string(),
  isMandatory: Yup.boolean(),
  displayOrder: Yup.number().min(0),
});

const FormInput = React.memo(({ name, label, multiline, rows, type = 'text' }) => (
  <FastField name={name}>
    {({ field, meta }) => (
      <TextField
        {...field}
        fullWidth size="small" label={label}
        type={type} multiline={multiline} rows={rows}
        error={meta.touched && Boolean(meta.error)}
        helperText={meta.touched ? meta.error : ''}
        sx={{ '& .MuiOutlinedInput-root': { borderRadius: '10px', bgcolor: '#F8FAFF' } }}
      />
    )}
  </FastField>
));

export default function RequirementsPage() {
  const [documentTypes, setDocumentTypes] = useState([]);
  const [requirements, setRequirements] = useState([]);
  const [loading, setLoading] = useState(true);
  const [open, setOpen] = useState(false);
  const [editData, setEditData] = useState(null);
  const [apiError, setApiError] = useState('');
  const [deleteConfirm, setDeleteConfirm] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [types, reqs] = await Promise.all([
        metaService.getTypes(),
        metaService.getRequirements(),
      ]);
      setDocumentTypes(types);
      setRequirements(reqs);
    } catch (e) {
      setApiError('Failed to load data.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  const handleOpen = (req = null) => {
    setEditData(req);
    setApiError('');
    setOpen(true);
  };

  const handleDelete = async (id) => {
    try {
      await metaService.deleteRequirement(id);
      setRequirements(prev => prev.filter(r => r.id !== id));
    } catch {
      setApiError('Failed to delete requirement.');
    }
    setDeleteConfirm(null);
  };

  // Group requirements by documentTypeId
  const grouped = documentTypes.map(dt => ({
    ...dt,
    reqs: requirements.filter(r => r.documentTypeId === dt.id)
      .sort((a, b) => a.displayOrder - b.displayOrder),
  }));

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: '#F4F7FE' }}>
      <Container maxWidth="lg" sx={{ py: 5 }}>

        {/* Header */}
        <Stack direction={{ xs: 'column', sm: 'row' }} justifyContent="space-between" alignItems="center" sx={{ mb: 5 }}>
          <Box>
            <Typography variant="h4" fontWeight={900} color={DARK}>
              Document <span style={{ color: NAVY }}>Requirements</span>
            </Typography>
            <Typography color={SLATE}>Manage requirements per document type.</Typography>
          </Box>
          <Button
            variant="contained" startIcon={<AddRoundedIcon />}
            onClick={() => handleOpen()}
            sx={{ bgcolor: NAVY, borderRadius: '12px', textTransform: 'none', fontWeight: 700, px: 3, py: 1.5, '&:hover': { bgcolor: '#0D145A' } }}
          >
            Add Requirement
          </Button>
        </Stack>

        <Collapse in={!!apiError}>
          <Alert severity="error" sx={{ mb: 3, borderRadius: 3 }} onClose={() => setApiError('')}>{apiError}</Alert>
        </Collapse>

        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}><CircularProgress /></Box>
        ) : grouped.length === 0 ? (
          <Card elevation={0} sx={{ p: 6, borderRadius: '24px', textAlign: 'center', border: '2px dashed #E0E4EC' }}>
            <Typography color={SLATE}>No document types found. Add document types first.</Typography>
          </Card>
        ) : (
          <Stack spacing={2}>
            {grouped.map((dt) => (
              <Accordion key={dt.id} elevation={0} sx={{
                borderRadius: '20px !important', border: '1px solid #f0f0f0',
                '&:before': { display: 'none' }, overflow: 'hidden'
              }}>
                <AccordionSummary expandIcon={<ExpandMoreIcon />} sx={{ px: 3, py: 1 }}>
                  <Stack direction="row" spacing={2} alignItems="center" sx={{ flex: 1 }}>
                    <Box sx={{ p: 1, bgcolor: `${NAVY}10`, borderRadius: '10px', display: 'flex' }}>
                      <DescriptionOutlinedIcon sx={{ color: NAVY, fontSize: 20 }} />
                    </Box>
                    <Box sx={{ flex: 1 }}>
                      <Typography fontWeight={800} color={DARK}>{dt.name}</Typography>
                      <Typography variant="caption" color={SLATE}>
                        {dt.reqs.length} {dt.reqs.length === 1 ? 'requirement' : 'requirements'}
                      </Typography>
                    </Box>
                    <Chip
                      label={dt.isActive ? 'Active' : 'Inactive'}
                      size="small"
                      sx={{
                        bgcolor: dt.isActive ? '#E8F5E9' : '#F4F7FE',
                        color: dt.isActive ? '#1B5E20' : SLATE,
                        fontWeight: 700, fontSize: '0.7rem'
                      }}
                    />
                  </Stack>
                </AccordionSummary>

                <AccordionDetails sx={{ px: 3, pb: 3, pt: 0 }}>
                  <Divider sx={{ mb: 2 }} />

                  {dt.reqs.length === 0 ? (
                    <Typography variant="body2" color={SLATE} sx={{ fontStyle: 'italic', mb: 2 }}>
                      No requirements added yet.
                    </Typography>
                  ) : (
                    <Stack spacing={1.5} sx={{ mb: 2 }}>
                      {dt.reqs.map((req) => (
                        <Box key={req.id} sx={{
                          display: 'flex', alignItems: 'center', gap: 2,
                          p: 2, bgcolor: '#F8FAFF', borderRadius: '12px', border: '1px solid #E0E5F2'
                        }}>
                          <CheckCircleOutlineIcon sx={{ color: req.isMandatory ? '#10B981' : SLATE, fontSize: 18, flexShrink: 0 }} />
                          <Box sx={{ flex: 1 }}>
                            <Typography variant="body2" fontWeight={700} color={DARK}>
                              {req.requirementName}
                              {req.isMandatory && (
                                <Typography component="span" variant="caption" sx={{ ml: 1, color: '#10B981', fontWeight: 700 }}>
                                  Required
                                </Typography>
                              )}
                            </Typography>
                            {req.description && (
                              <Typography variant="caption" color={SLATE}>{req.description}</Typography>
                            )}
                          </Box>
                          <Stack direction="row">
                            <IconButton size="small" onClick={() => handleOpen(req)}>
                              <EditRoundedIcon fontSize="small" sx={{ color: NAVY }} />
                            </IconButton>
                            <IconButton size="small" onClick={() => setDeleteConfirm(req)}>
                              <DeleteOutlineRoundedIcon fontSize="small" sx={{ color: '#EF4444' }} />
                            </IconButton>
                          </Stack>
                        </Box>
                      ))}
                    </Stack>
                  )}

                  <Button
                    size="small" startIcon={<AddRoundedIcon />}
                    onClick={() => handleOpen({ documentTypeId: dt.id })}
                    sx={{ textTransform: 'none', fontWeight: 700, color: NAVY }}
                  >
                    Add to {dt.name}
                  </Button>
                </AccordionDetails>
              </Accordion>
            ))}
          </Stack>
        )}

        {/* Add / Edit Dialog */}
        <Dialog open={open} onClose={() => setOpen(false)} fullWidth maxWidth="sm"
          PaperProps={{ sx: { borderRadius: '24px' } }}>
          <Formik
            enableReinitialize
            initialValues={{
              documentTypeId: editData?.documentTypeId ?? '',
              requirementName: editData?.requirementName ?? '',
              description: editData?.description ?? '',
              isMandatory: editData?.isMandatory ?? true,
              displayOrder: editData?.displayOrder ?? 0,
            }}
            validationSchema={schema}
            onSubmit={async (values, { setSubmitting }) => {
              setApiError('');
              try {
                if (editData?.id) {
                  await metaService.updateRequirement(editData.id, values);
                } else {
                  await metaService.createRequirement(values);
                }
                await load();
                setOpen(false);
              } catch (e) {
                setApiError(e.message || 'Failed to save.');
              } finally {
                setSubmitting(false);
              }
            }}
          >
            {({ handleSubmit, isSubmitting, values, setFieldValue }) => (
              <Box component="form" onSubmit={handleSubmit} noValidate>
                <DialogTitle sx={{ fontWeight: 900, pt: 3 }}>
                  {editData?.id ? 'Edit Requirement' : 'Add Requirement'}
                </DialogTitle>
                <DialogContent>
                  <Stack spacing={2.5} sx={{ mt: 1 }}>
                    <Collapse in={!!apiError}>
                      <Alert severity="error" sx={{ borderRadius: 3 }}>{apiError}</Alert>
                    </Collapse>

                    <FastField name="documentTypeId">
                      {({ field, meta }) => (
                        <TextField
                          {...field} select fullWidth size="small" label="Document Type"
                          error={meta.touched && Boolean(meta.error)}
                          helperText={meta.touched ? meta.error : ''}
                          sx={{ '& .MuiOutlinedInput-root': { borderRadius: '10px', bgcolor: '#F8FAFF' } }}
                        >
                          {documentTypes.map(dt => (
                            <MenuItem key={dt.id} value={dt.id}>{dt.name}</MenuItem>
                          ))}
                        </TextField>
                      )}
                    </FastField>

                    <FormInput name="requirementName" label="Requirement Name" />
                    <FormInput name="description" label="Description (optional)" multiline rows={2} />

                    <Stack direction="row" spacing={2}>
                      <FormInput name="displayOrder" label="Display Order" type="number" />
                      <FormControlLabel
                        control={
                          <Switch
                            checked={values.isMandatory}
                            onChange={e => setFieldValue('isMandatory', e.target.checked)}
                            sx={{ '& .MuiSwitch-switchBase.Mui-checked': { color: NAVY } }}
                          />
                        }
                        label="Mandatory"
                        sx={{ mt: 0.5 }}
                      />
                    </Stack>
                  </Stack>
                </DialogContent>
                <DialogActions sx={{ p: 3, pt: 0 }}>
                  <Button onClick={() => setOpen(false)} sx={{ color: SLATE, fontWeight: 700 }}>Cancel</Button>
                  <Button type="submit" variant="contained" disabled={isSubmitting}
                    sx={{ bgcolor: NAVY, borderRadius: '10px', fontWeight: 700, textTransform: 'none', px: 3 }}>
                    {isSubmitting ? <CircularProgress size={20} color="inherit" /> : 'Save'}
                  </Button>
                </DialogActions>
              </Box>
            )}
          </Formik>
        </Dialog>

        {/* Delete Confirm Dialog */}
        <Dialog open={!!deleteConfirm} onClose={() => setDeleteConfirm(null)}
          PaperProps={{ sx: { borderRadius: '20px', p: 1 } }}>
          <DialogTitle sx={{ fontWeight: 900 }}>Delete Requirement</DialogTitle>
          <DialogContent>
            <Typography>
              Delete <strong>"{deleteConfirm?.requirementName}"</strong>? This cannot be undone.
            </Typography>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setDeleteConfirm(null)} sx={{ color: SLATE, fontWeight: 700 }}>Cancel</Button>
            <Button variant="contained" onClick={() => handleDelete(deleteConfirm.id)}
              sx={{ bgcolor: '#EF4444', borderRadius: '10px', fontWeight: 700, textTransform: 'none', '&:hover': { bgcolor: '#DC2626' } }}>
              Delete
            </Button>
          </DialogActions>
        </Dialog>

      </Container>
    </Box>
  );
}
