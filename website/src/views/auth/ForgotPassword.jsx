import React, { useState, useRef } from 'react';
import {
  Box, Container, Paper, Typography, TextField,
  Button, Stack, Alert, CircularProgress, Link as MuiLink
} from '@mui/material';
import { Link, useNavigate } from 'react-router-dom';
import { Formik, FastField } from 'formik';
import * as Yup from 'yup';
import { UseAuth } from '../../context/AuthContext';

// Reusable OTP boxes (same pattern as Signup)
const OtpInput = ({ value, onChange }) => {
  const inputs = useRef([]);
  const digits = value.split('');

  const handleChange = (e, index) => {
    const val = e.target.value.replace(/\D/, '');
    const newDigits = [...digits];
    newDigits[index] = val.slice(-1);
    onChange(newDigits.join(''));
    if (val && index < 5) inputs.current[index + 1]?.focus();
  };

  const handleKeyDown = (e, index) => {
    if (e.key === 'Backspace' && !digits[index] && index > 0)
      inputs.current[index - 1]?.focus();
  };

  const handlePaste = (e) => {
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    onChange(pasted.padEnd(6, '').slice(0, 6));
    e.preventDefault();
  };

  return (
    <Stack direction="row" spacing={1} justifyContent="center">
      {Array.from({ length: 6 }).map((_, i) => (
        <TextField
          key={i}
          inputRef={(el) => (inputs.current[i] = el)}
          value={digits[i] || ''}
          onChange={(e) => handleChange(e, i)}
          onKeyDown={(e) => handleKeyDown(e, i)}
          onPaste={handlePaste}
          inputProps={{ maxLength: 1, style: { textAlign: 'center', fontSize: 22, fontWeight: 700 } }}
          sx={{ width: 52, '& .MuiOutlinedInput-root': { borderRadius: 2 } }}
        />
      ))}
    </Stack>
  );
};

const emailSchema = Yup.object({
  email: Yup.string().email('Invalid email').required('Email is required'),
});

const resetSchema = Yup.object({
  newPassword: Yup.string().min(8, 'At least 8 characters').required('Required'),
  confirmPassword: Yup.string()
    .oneOf([Yup.ref('newPassword')], 'Passwords must match')
    .required('Required'),
});

// step: 'email' | 'otp' | 'reset'
export default function ForgotPassword() {
  const { forgotPassword, resetPassword } = UseAuth();
  const navigate = useNavigate();

  const [step, setStep] = useState('email');
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [error, setError] = useState('');
  const [otpLoading, setOtpLoading] = useState(false);

  // ── Step 1: Email ────────────────────────────────────────────
  if (step === 'email') {
    return (
      <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', bgcolor: '#F5F7FA', py: 5 }}>
        <Container maxWidth="xs">
          <Paper elevation={0} sx={{ p: { xs: 4, md: 6 }, borderRadius: 6, border: '1px solid rgba(0,0,0,0.05)', textAlign: 'center' }}>
            <Stack spacing={1} sx={{ mb: 4 }}>
              <Typography variant="h5" fontWeight={900} color="#1A237E">Forgot Password</Typography>
              <Typography variant="body2" color="text.secondary">
                Enter your registered email and we'll send a reset code.
              </Typography>
            </Stack>

            {error && <Alert severity="error" sx={{ mb: 2, borderRadius: 2 }}>{error}</Alert>}

            <Formik
              initialValues={{ email: '' }}
              validationSchema={emailSchema}
              validateOnBlur
              validateOnChange={false}
              onSubmit={async (values, { setSubmitting }) => {
                setError('');
                try {
                  await forgotPassword({ email: values.email });
                  setEmail(values.email);
                  setStep('otp');
                } catch (err) {
                  setError(err.message || 'Something went wrong.');
                } finally {
                  setSubmitting(false);
                }
              }}
            >
              {({ handleSubmit, isSubmitting }) => (
                <Box component="form" onSubmit={handleSubmit} noValidate>
                  <FastField name="email">
                    {({ field, meta }) => (
                      <TextField
                        {...field}
                        fullWidth
                        label="Email Address"
                        type="email"
                        error={meta.touched && Boolean(meta.error)}
                        helperText={meta.touched ? meta.error : ''}
                        sx={{ mb: 3, '& .MuiOutlinedInput-root': { borderRadius: 2 } }}
                      />
                    )}
                  </FastField>
                  <Button
                    type="submit"
                    fullWidth
                    variant="contained"
                    size="large"
                    disabled={isSubmitting}
                    sx={{ py: 1.5, borderRadius: 3, bgcolor: '#1A237E', fontWeight: 700, '&:hover': { bgcolor: '#311B92' } }}
                  >
                    {isSubmitting ? <CircularProgress size={24} color="inherit" /> : 'Send Reset Code'}
                  </Button>
                </Box>
              )}
            </Formik>

            <Typography variant="body2" sx={{ mt: 3 }} color="text.secondary">
              Remember your password?{' '}
              <MuiLink component={Link} to="/login" sx={{ fontWeight: 700, color: '#1A237E', textDecoration: 'none' }}>
                Log In
              </MuiLink>
            </Typography>
          </Paper>
        </Container>
      </Box>
    );
  }

  // ── Step 2: OTP ──────────────────────────────────────────────
  if (step === 'otp') {
    const handleVerifyOtp = async () => {
      if (otp.length < 6) { setError('Please enter the complete 6-digit code.'); return; }
      setOtpLoading(true);
      setError('');
      try {
        // Just validate OTP exists — actual reset happens in next step
        // We move forward and pass otp to reset step
        setStep('reset');
      } finally {
        setOtpLoading(false);
      }
    };

    return (
      <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', bgcolor: '#F5F7FA', py: 5 }}>
        <Container maxWidth="xs">
          <Paper elevation={0} sx={{ p: { xs: 4, md: 6 }, borderRadius: 6, border: '1px solid rgba(0,0,0,0.05)', textAlign: 'center' }}>
            <Stack spacing={1} sx={{ mb: 4 }}>
              <Typography variant="h5" fontWeight={900} color="#1A237E">Enter Reset Code</Typography>
              <Typography variant="body2" color="text.secondary">
                We sent a 6-digit code to <strong>{email}</strong>
              </Typography>
            </Stack>

            {error && <Alert severity="error" sx={{ mb: 2, borderRadius: 2 }}>{error}</Alert>}

            <OtpInput value={otp} onChange={setOtp} />

            <Button
              fullWidth
              variant="contained"
              size="large"
              disabled={otpLoading}
              onClick={handleVerifyOtp}
              sx={{ mt: 4, py: 1.5, borderRadius: 3, bgcolor: '#1A237E', fontWeight: 700, '&:hover': { bgcolor: '#311B92' } }}
            >
              {otpLoading ? <CircularProgress size={24} color="inherit" /> : 'Continue'}
            </Button>

            <Button
              fullWidth
              variant="text"
              onClick={() => setStep('email')}
              sx={{ mt: 1, borderRadius: 3, color: '#1A237E', fontWeight: 600 }}
            >
              Back
            </Button>
          </Paper>
        </Container>
      </Box>
    );
  }

  // ── Step 3: New Password ─────────────────────────────────────
  return (
    <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', bgcolor: '#F5F7FA', py: 5 }}>
      <Container maxWidth="xs">
        <Paper elevation={0} sx={{ p: { xs: 4, md: 6 }, borderRadius: 6, border: '1px solid rgba(0,0,0,0.05)', textAlign: 'center' }}>
          <Stack spacing={1} sx={{ mb: 4 }}>
            <Typography variant="h5" fontWeight={900} color="#1A237E">Set New Password</Typography>
            <Typography variant="body2" color="text.secondary">
              Choose a strong new password for your account.
            </Typography>
          </Stack>

          {error && <Alert severity="error" sx={{ mb: 2, borderRadius: 2 }}>{error}</Alert>}

          <Formik
            initialValues={{ newPassword: '', confirmPassword: '' }}
            validationSchema={resetSchema}
            validateOnBlur
            validateOnChange={false}
            onSubmit={async (values, { setSubmitting }) => {
              setError('');
              try {
                await resetPassword({ email, otp, newPassword: values.newPassword });
                navigate('/login', { state: { message: 'Password reset successful. Please log in.' } });
              } catch (err) {
                setError(err.message || 'Failed to reset password. The code may have expired.');
              } finally {
                setSubmitting(false);
              }
            }}
          >
            {({ handleSubmit, isSubmitting }) => (
              <Box component="form" onSubmit={handleSubmit} noValidate>
                <Stack spacing={2} sx={{ mb: 3 }}>
                  <FastField name="newPassword">
                    {({ field, meta }) => (
                      <TextField
                        {...field}
                        fullWidth
                        label="New Password"
                        type="password"
                        error={meta.touched && Boolean(meta.error)}
                        helperText={meta.touched ? meta.error : ''}
                        sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2 } }}
                      />
                    )}
                  </FastField>
                  <FastField name="confirmPassword">
                    {({ field, meta }) => (
                      <TextField
                        {...field}
                        fullWidth
                        label="Confirm New Password"
                        type="password"
                        error={meta.touched && Boolean(meta.error)}
                        helperText={meta.touched ? meta.error : ''}
                        sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2 } }}
                      />
                    )}
                  </FastField>
                </Stack>
                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  size="large"
                  disabled={isSubmitting}
                  sx={{ py: 1.5, borderRadius: 3, bgcolor: '#1A237E', fontWeight: 700, '&:hover': { bgcolor: '#311B92' } }}
                >
                  {isSubmitting ? <CircularProgress size={24} color="inherit" /> : 'Reset Password'}
                </Button>
              </Box>
            )}
          </Formik>
        </Paper>
      </Container>
    </Box>
  );
}
