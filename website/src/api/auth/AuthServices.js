import { request } from '../Client';

export const authService = {
  register: (data) => request('/Auth/register', { method: 'POST', body: data }),
  verifyEmail: (data) => request('/Auth/verify-email', { method: 'POST', body: data }),
  resendOtp: (data) => request('/Auth/resend-otp', { method: 'POST', body: data }),
  login: (data) => request('/Auth/login', { method: 'POST', body: data }),
  changePassword: (data) => request('/Auth/change-password', { method: 'POST', body: data }),
  forgotPassword: (data) => request('/Auth/forgot-password', { method: 'POST', body: data }),
  resetPassword: (data) => request('/Auth/reset-password', { method: 'POST', body: data }),
};
