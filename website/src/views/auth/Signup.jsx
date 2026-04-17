import React, { useState, useRef } from 'react';
import {
  Box, Container, Paper, Typography, TextField,
  Button, Grid, Link as MuiLink, Stack, CircularProgress, Alert
} from '@mui/material';
import { Link, useNavigate } from 'react-router-dom';
import { Formik, FastField } from 'formik';
import * as Yup from 'yup';
import { UseAuth } from '../../context/AuthContext';

// Validation Schema
const validationSchema = Yup.object({
  firstName: Yup.string().required('First name is required'),
  lastName: Yup.string().required('Last name is required'),
  email: Yup.string().email('Enter a valid email').required('Email is required'),
  studentId: Yup.string().required('Student ID is required'),
  password: Yup.string().min(8, 'At least 8 characters').required('Password is required'),
  confirmPassword: Yup.string()
    .oneOf([Yup.ref('password'), null], 'Passwords must match')
    .required('Confirm password is required'),
});

// Reusable Input
const FormInput = React.memo(({ name, label, type = 'text', ...props }) => (
  <FastField name={name}>
    {({ field, meta }) => (
      <TextField
        {...field}
        {...props}
        fullWidth
        type={type}
        label={label}
        error={meta.touched && Boolean(meta.error)}
        helperText={meta.touched ? meta.error : ''}
        sx={{ '& .MuiOutlinedInput-root': { borderRadius: 3 } }}
      />
    )}
  </FastField>
));

// OTP Input — 6 individual boxes
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
    if (e.key === 'Backspace' && !digits[index] && index > 0) {
      inputs.current[index - 1]?.focus();
    }
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

const Register = () => {
  const { register, verifyEmail, resendOtp } = UseAuth();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [otpStep, setOtpStep] = useState(false);
  const [registeredEmail, setRegisteredEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [otpLoading, setOtpLoading] = useState(false);
  const [otpError, setOtpError] = useState('');
  const [resendLoading, setResendLoading] = useState(false);
  const [resendMsg, setResendMsg] = useState('');

  const handleVerify = async () => {
    if (otp.length < 6) {
      setOtpError('Please enter the complete 6-digit OTP.');
      return;
    }
    setOtpLoading(true);
    setOtpError('');
    try {
      await verifyEmail({ email: registeredEmail, otp });
      navigate('/login');
    } catch (err) {
      setOtpError(err.message || 'Invalid or expired OTP.');
    } finally {
      setOtpLoading(false);
    }
  };

  const handleResend = async () => {
    setResendLoading(true);
    setResendMsg('');
    setOtpError('');
    try {
      await resendOtp({ email: registeredEmail });
      setResendMsg('A new OTP has been sent to your email.');
    } catch (err) {
      setOtpError(err.message || 'Failed to resend OTP.');
    } finally {
      setResendLoading(false);
    }
  };

  // ── OTP Step UI ──────────────────────────────────────────────
  if (otpStep) {
    return (
      <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', bgcolor: '#F5F7FA', py: 5 }}>
        <Container maxWidth="xs">
          <Paper elevation={0} sx={{ p: { xs: 4, md: 6 }, borderRadius: 6, border: '1px solid rgba(0,0,0,0.05)', textAlign: 'center' }}>
            <Stack spacing={1} sx={{ mb: 4 }}>
              <Typography variant="h5" fontWeight={900} color="#1A237E">Verify your email</Typography>
              <Typography variant="body2" color="text.secondary">
                We sent a 6-digit code to <strong>{registeredEmail}</strong>
              </Typography>
            </Stack>

            {otpError && <Alert severity="error" sx={{ mb: 2, borderRadius: 2 }}>{otpError}</Alert>}
            {resendMsg && <Alert severity="success" sx={{ mb: 2, borderRadius: 2 }}>{resendMsg}</Alert>}

            <OtpInput value={otp} onChange={setOtp} />

            <Button
              fullWidth
              variant="contained"
              size="large"
              disabled={otpLoading}
              onClick={handleVerify}
              sx={{ mt: 4, mb: 2, py: 1.5, borderRadius: 3, bgcolor: '#1A237E', fontWeight: 700, '&:hover': { bgcolor: '#311B92' } }}
            >
              {otpLoading ? <CircularProgress size={24} color="inherit" /> : 'Verify'}
            </Button>

            <Button
              fullWidth
              variant="text"
              disabled={resendLoading}
              onClick={handleResend}
              sx={{ borderRadius: 3, color: '#1A237E', fontWeight: 600 }}
            >
              {resendLoading ? <CircularProgress size={20} color="inherit" /> : 'Resend OTP'}
            </Button>
          </Paper>
        </Container>
      </Box>
    );
  }

  // ── Registration Step UI ─────────────────────────────────────
  return (
    <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', bgcolor: '#F5F7FA', py: 5 }}>
      <Container maxWidth="sm">
        <Paper elevation={0} sx={{ p: { xs: 4, md: 6 }, borderRadius: 6, border: '1px solid rgba(0,0,0,0.05)' }}>

          <Stack spacing={1} sx={{ mb: 4, textAlign: 'center' }}>
            <Typography variant="h4" fontWeight={900} color="#1A237E">Create Account</Typography>
            <Typography variant="body2" color="text.secondary">
              Please enter your official details for RegisTrack.
            </Typography>
          </Stack>

          {error && <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>{error}</Alert>}

          <Formik
            initialValues={{ firstName: '', lastName: '', email: '', studentId: '', password: '', confirmPassword: '' }}
            validationSchema={validationSchema}
            validateOnChange={false}
            validateOnBlur={true}
            onSubmit={async (values, { setSubmitting }) => {
              setLoading(true);
              setError('');
              try {
                await register(values);
                setRegisteredEmail(values.email);
                setOtpStep(true);
              } catch (err) {
                setError(err.message || 'Registration failed. Please try again.');
              } finally {
                setLoading(false);
                setSubmitting(false);
              }
            }}
          >
            {({ handleSubmit }) => (
              <Box component="form" onSubmit={handleSubmit} noValidate>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6}>
                    <FormInput name="firstName" label="First Name" />
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <FormInput name="lastName" label="Last Name" />
                  </Grid>
                  <Grid item xs={12}>
                    <FormInput name="studentId" label="Student ID" placeholder="e.g. 2024-0001" />
                  </Grid>
                  <Grid item xs={12}>
                    <FormInput name="email" label="Email Address" type="email" />
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <FormInput name="password" label="Password" type="password" />
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <FormInput name="confirmPassword" label="Confirm Password" type="password" />
                  </Grid>
                </Grid>

                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  size="large"
                  disabled={loading}
                  sx={{ mt: 4, mb: 3, py: 1.5, borderRadius: 3, bgcolor: '#1A237E', fontWeight: 700, '&:hover': { bgcolor: '#311B92' } }}
                >
                  {loading ? <CircularProgress size={24} color="inherit" /> : 'Register Account'}
                </Button>

                <Typography variant="body2" textAlign="center" color="text.secondary">
                  Already have an account?{' '}
                  <MuiLink component={Link} to="/login" sx={{ fontWeight: 700, color: '#1A237E', textDecoration: 'none' }}>
                    Log In here
                  </MuiLink>
                </Typography>
              </Box>
            )}
          </Formik>

        </Paper>
      </Container>
    </Box>
  );
};

export default Register;
