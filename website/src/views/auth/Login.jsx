import React, { useState } from 'react';
import { 
  Box, Grid, Paper, Typography, TextField, 
  Button, Link as MuiLink, 
  Stack, InputAdornment, IconButton, Alert 
} from '@mui/material';
import { Link, useNavigate } from 'react-router-dom';
import { UseAuth } from '../../context/AuthContext'; 
import { Formik, FastField } from 'formik';
import * as Yup from 'yup';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';

// ✅ Validation
const validationSchema = Yup.object({
  email: Yup.string().email('Enter a valid email').required('Email is required'),
  password: Yup.string().required('Password is required'),
});

const FormInput = React.memo(({ name, label, type = "text", showPassword, togglePassword }) => {
  return (
    <FastField name={name}>
      {({ field, meta }) => (
        <TextField
          {...field}
          fullWidth
          margin="normal"
          label={label}
          type={type === 'password' ? (showPassword ? 'text' : 'password') : type}
          error={meta.touched && Boolean(meta.error)}
          helperText={meta.touched ? meta.error : ""}
          InputProps={
            type === 'password'
              ? {
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton onClick={togglePassword}>
                        {showPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }
              : undefined
          }
          sx={{ '& .MuiOutlinedInput-root': { borderRadius: 3 } }}
        />
      )}
    </FastField>
  );
});

const Login = () => {
  const { login } = UseAuth();
  const navigate = useNavigate();
  
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');

  return (
    <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', p: 0 }}>
      <Grid container component="main" sx={{ height: '100vh' }}>
        
        {/* LEFT SIDE */}
        <Grid
          item xs={false} sm={4} md={7}
          sx={{
            background: 'linear-gradient(135deg, #1A237E 0%, #311B92 100%)',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            color: 'white',
            p: 4
          }}
        >
          <Typography variant="h2" fontWeight={900} sx={{ mb: 2 }}>RegisTrack</Typography>
          <Typography variant="h6" sx={{ textAlign: 'center', maxWidth: 500, opacity: 0.9 }}>
            Ang modernong paagi sa pag-request ug pag-track sa imong academic documents.
          </Typography>
        </Grid>

        {/* RIGHT SIDE */}
        <Grid item xs={12} sm={8} md={5} component={Paper} elevation={6} square sx={{ display: 'flex', alignItems: 'center' }}>
          <Box sx={{ my: 8, mx: { xs: 4, md: 10 }, width: '100%' }}>
            
            <Stack spacing={1} sx={{ mb: 4 }}>
              <Typography variant="h4" fontWeight={800} color="#1A237E">Welcome Back!</Typography>
              <Typography variant="body2" color="text.secondary">
                Please provide your account details
              </Typography>
            </Stack>

            {error && <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>{error}</Alert>}

            {/* ✅ FORMIK */}
            <Formik
              initialValues={{
                email: '',
                password: '',
              }}
              validationSchema={validationSchema}
              validateOnChange={false}
              validateOnBlur={true}
              onSubmit={async (values, { setSubmitting }) => {
                setError('');

                const result = await login(values);

                if (result.success) {
                  const userRole = result.user?.role;

                  if (userRole === 'Admin') {
                    navigate('/admin/dashboard');
                  }else{
                    navigate('/dashboard');
                  } 
                  

                } else {
                  setError(result.message || 'Sayop ang email o password.');
                }

                setSubmitting(false);
              }}
            >
              {({ handleSubmit, isSubmitting }) => (
                <Box component="form" noValidate onSubmit={handleSubmit}>
                  
                  <FormInput name="email" label="Email Address" type="email" />

                  <FormInput 
                    name="password" 
                    label="Password" 
                    type="password"
                    showPassword={showPassword}
                    togglePassword={() => setShowPassword(!showPassword)}
                  />

                  <Button
                    fullWidth
                    type="submit"
                    variant="contained"
                    size="large"
                    disabled={isSubmitting}
                    sx={{ 
                      mt: 4, mb: 3, py: 1.5, borderRadius: 3, 
                      bgcolor: '#1A237E', fontWeight: 700,
                      '&:hover': { bgcolor: '#311B92' }
                    }}
                  >
                    {isSubmitting ? 'Nag-log in...' : 'Log In'}
                  </Button>

                  <Typography variant="body2" textAlign="center" color="text.secondary">
                    You don't have an Account{' '}
                    <MuiLink 
                      component={Link} 
                      to="/register" 
                      sx={{ fontWeight: 700, color: '#1A237E', textDecoration: 'none' }}
                    >
                      Sign Up now!
                    </MuiLink>
                  </Typography>

                </Box>
              )}
            </Formik>

          </Box>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Login;