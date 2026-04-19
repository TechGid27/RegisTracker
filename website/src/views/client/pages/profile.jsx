import React, { useState } from 'react';
import {
  Box, Container, Typography, TextField, Button,
  Stack, Alert, Avatar, InputAdornment, IconButton,
  CircularProgress, Divider
} from '@mui/material';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import PersonOutlineIcon from '@mui/icons-material/PersonOutline';
import BadgeOutlinedIcon from '@mui/icons-material/BadgeOutlined';
import AlternateEmailIcon from '@mui/icons-material/AlternateEmail';
import LockPersonOutlinedIcon from '@mui/icons-material/LockPersonOutlined';
import { Formik, FastField } from 'formik';
import * as Yup from 'yup';
import { UseAuth } from '../../../context/AuthContext';

// ── Design tokens (mirrors mobile palette) ──────────────────────
const NAVY = '#1A237E';
const SLATE = '#64748B';
const DARK = '#0F172A';
const BG_FROM = '#F6F7FF';
const BG_TO = '#EEF2FF';

// ── Glass card (mirrors GlassContainer) ─────────────────────────
function GlassCard({ children, sx = {} }) {
  return (
    <Box
      sx={{
        width: '100%',
        bgcolor: 'rgba(255,255,255,0.92)',
        border: '1px solid #E7E9F4',
        borderRadius: '16px',
        boxShadow: '0 10px 20px rgba(0,0,0,0.08)',
        p: 3,
        ...sx,
      }}
    >
      {children}
    </Box>
  );
}

// ── Section label (mirrors _buildSectionLabel) ───────────────────
function SectionLabel({ children }) {
  return (
    <Typography
      sx={{
        color: SLATE,
        fontSize: 11,
        fontWeight: 800,
        letterSpacing: 1.2,
        textTransform: 'uppercase',
        mb: 1.25,
      }}
    >
      {children}
    </Typography>
  );
}

// ── Inline alert (mirrors _buildAlert) ──────────────────────────
function InlineAlert({ message, type, onClose }) {
  if (!message) return null;
  const isError = type === 'error';
  return (
    <Box
      sx={{
        display: 'flex',
        alignItems: 'center',
        gap: 1,
        p: 1.5,
        mb: 2,
        borderRadius: '10px',
        bgcolor: isError ? '#fff5f5' : '#f0fdf4',
        border: `1px solid ${isError ? '#fca5a5' : '#86efac'}`,
      }}
    >
      <Typography sx={{ fontSize: 13, fontWeight: 600, color: isError ? '#b91c1c' : '#15803d', flex: 1 }}>
        {message}
      </Typography>
      {onClose && (
        <IconButton size="small" onClick={onClose} sx={{ p: 0.25 }}>
          <Typography sx={{ fontSize: 14, color: SLATE }}>✕</Typography>
        </IconButton>
      )}
    </Box>
  );
}

// ── Shared text field ────────────────────────────────────────────
const ProfileField = React.memo(({ name, label, icon, type = 'text', showPw, togglePw }) => (
  <FastField name={name}>
    {({ field, meta }) => (
      <TextField
        {...field}
        fullWidth
        size="small"
        label={label}
        type={type === 'password' ? (showPw ? 'text' : 'password') : type}
        error={meta.touched && Boolean(meta.error)}
        helperText={meta.touched ? meta.error : ''}
        InputProps={{
          startAdornment: icon ? (
            <InputAdornment position="start">{icon}</InputAdornment>
          ) : undefined,
          endAdornment:
            type === 'password' ? (
              <InputAdornment position="end">
                <IconButton onClick={togglePw} size="small" edge="end">
                  {showPw ? <VisibilityOff fontSize="small" /> : <Visibility fontSize="small" />}
                </IconButton>
              </InputAdornment>
            ) : undefined,
        }}
        sx={{
          '& .MuiOutlinedInput-root': { borderRadius: '10px' },
          '& .MuiInputLabel-root': { fontSize: 14 },
        }}
      />
    )}
  </FastField>
));

// ── Validation schemas ───────────────────────────────────────────
const profileSchema = Yup.object({
  firstName: Yup.string().required('Required'),
  lastName: Yup.string().required('Required'),
  email: Yup.string().email('Invalid email').required('Required'),
});

const passwordSchema = Yup.object({
  currentPassword: Yup.string().required('Required'),
  newPassword: Yup.string().min(8, 'Min 8 characters').required('Required'),
  confirmPassword: Yup.string()
    .oneOf([Yup.ref('newPassword')], 'Passwords do not match')
    .required('Required'),
});

// ── Save button ──────────────────────────────────────────────────
function SaveButton({ label, isSubmitting }) {
  return (
    <Button
      type="submit"
      fullWidth
      variant="contained"
      disabled={isSubmitting}
      sx={{
        mt: 2.5,
        py: 1.5,
        borderRadius: '12px',
        bgcolor: NAVY,
        fontWeight: 700,
        fontSize: 15,
        textTransform: 'none',
        boxShadow: 'none',
        '&:hover': { bgcolor: '#311B92', boxShadow: 'none' },
      }}
    >
      {isSubmitting ? <CircularProgress size={22} color="inherit" /> : label}
    </Button>
  );
}

// ── Main page ────────────────────────────────────────────────────
export default function ProfilePage() {
  const { user, updateUser, changePassword } = UseAuth();

  const [profileMsg, setProfileMsg] = useState(null);
  const [pwMsg, setPwMsg] = useState(null);

  // password visibility
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  const initials = user?.firstName?.charAt(0).toUpperCase() ?? '?';

  return (
    <Box
      sx={{
        minHeight: '100vh',
        background: `linear-gradient(135deg, ${BG_FROM} 0%, ${BG_TO} 60%, #ffffff 100%)`,
        py: 4,
      }}
    >
      <Container maxWidth="sm">
        <Stack spacing={3}>

          {/* ── Avatar card (mirrors _buildAvatarCard) ── */}
          <GlassCard>
            <Stack direction="row" spacing={2} alignItems="center">
              <Avatar
                sx={{
                  width: 72,
                  height: 72,
                  bgcolor: `${NAVY}14`,
                  color: NAVY,
                  fontSize: 32,
                  fontWeight: 900,
                }}
              >
                {initials}
              </Avatar>
              <Box>
                <Typography sx={{ fontSize: 18, fontWeight: 900, color: DARK, lineHeight: 1.2 }}>
                  {user?.firstName} {user?.lastName}
                </Typography>
                <Typography sx={{ color: SLATE, fontSize: 13, mt: 0.5 }}>
                  {user?.email}
                </Typography>
                {user?.studentId && (
                  <Box
                    sx={{
                      display: 'inline-block',
                      mt: 0.75,
                      px: 1.25,
                      py: 0.25,
                      bgcolor: '#F1F5FF',
                      border: '1px solid #E7E9F4',
                      borderRadius: '20px',
                    }}
                  >
                    <Typography sx={{ color: '#475569', fontSize: 12, fontWeight: 700 }}>
                      ID: {user.studentId}
                    </Typography>
                  </Box>
                )}
              </Box>
            </Stack>
          </GlassCard>

          {/* ── Edit Profile section ── */}
          <Box>
            <SectionLabel>Edit Profile</SectionLabel>
            <GlassCard>
              <InlineAlert
                message={profileMsg?.text}
                type={profileMsg?.type}
                onClose={() => setProfileMsg(null)}
              />
              <Formik
                initialValues={{
                  firstName: user?.firstName || '',
                  lastName: user?.lastName || '',
                  email: user?.email || '',
                }}
                validationSchema={profileSchema}
                validateOnBlur
                validateOnChange={false}
                onSubmit={async (values, { setSubmitting }) => {
                  setProfileMsg(null);
                  try {
                    await updateUser(user.id, values);
                    setProfileMsg({ type: 'success', text: 'Profile updated successfully.' });
                  } catch (err) {
                    setProfileMsg({ type: 'error', text: err.message || 'Failed to update profile.' });
                  } finally {
                    setSubmitting(false);
                  }
                }}
              >
                {({ handleSubmit, isSubmitting }) => (
                  <Box component="form" onSubmit={handleSubmit} noValidate>
                    <Stack spacing={1.75}>
                      <Stack direction="row" spacing={1.5}>
                        <ProfileField
                          name="firstName"
                          label="First Name"
                          icon={<PersonOutlineIcon sx={{ fontSize: 18, color: SLATE }} />}
                        />
                        <ProfileField
                          name="lastName"
                          label="Last Name"
                          icon={<BadgeOutlinedIcon sx={{ fontSize: 18, color: SLATE }} />}
                        />
                      </Stack>
                      <ProfileField
                        name="email"
                        label="Email"
                        type="email"
                        icon={<AlternateEmailIcon sx={{ fontSize: 18, color: SLATE }} />}
                      />
                    </Stack>
                    <SaveButton label="Save Profile" isSubmitting={isSubmitting} />
                  </Box>
                )}
              </Formik>
            </GlassCard>
          </Box>

          {/* ── Change Password section ── */}
          <Box>
            <SectionLabel>Change Password</SectionLabel>
            <GlassCard>
              <InlineAlert
                message={pwMsg?.text}
                type={pwMsg?.type}
                onClose={() => setPwMsg(null)}
              />
              <Formik
                initialValues={{ currentPassword: '', newPassword: '', confirmPassword: '' }}
                validationSchema={passwordSchema}
                validateOnBlur
                validateOnChange={false}
                onSubmit={async (values, { setSubmitting, resetForm }) => {
                  setPwMsg(null);
                  try {
                    await changePassword({
                      userId: user.id,
                      currentPassword: values.currentPassword,
                      newPassword: values.newPassword,
                    });
                    setPwMsg({ type: 'success', text: 'Password changed successfully.' });
                    resetForm();
                  } catch (err) {
                    setPwMsg({ type: 'error', text: err.message || 'Failed to change password.' });
                  } finally {
                    setSubmitting(false);
                  }
                }}
              >
                {({ handleSubmit, isSubmitting }) => (
                  <Box component="form" onSubmit={handleSubmit} noValidate>
                    <Stack spacing={1.75}>
                      <ProfileField
                        name="currentPassword"
                        label="Current Password"
                        type="password"
                        icon={<LockPersonOutlinedIcon sx={{ fontSize: 18, color: SLATE }} />}
                        showPw={showCurrent}
                        togglePw={() => setShowCurrent((p) => !p)}
                      />
                      <ProfileField
                        name="newPassword"
                        label="New Password"
                        type="password"
                        icon={<LockPersonOutlinedIcon sx={{ fontSize: 18, color: SLATE }} />}
                        showPw={showNew}
                        togglePw={() => setShowNew((p) => !p)}
                      />
                      <ProfileField
                        name="confirmPassword"
                        label="Confirm New Password"
                        type="password"
                        icon={<LockPersonOutlinedIcon sx={{ fontSize: 18, color: SLATE }} />}
                        showPw={showConfirm}
                        togglePw={() => setShowConfirm((p) => !p)}
                      />
                    </Stack>
                    <SaveButton label="Change Password" isSubmitting={isSubmitting} />
                  </Box>
                )}
              </Formik>
            </GlassCard>
          </Box>

          {/* bottom breathing room */}
          <Box sx={{ height: 32 }} />
        </Stack>
      </Container>
    </Box>
  );
}
