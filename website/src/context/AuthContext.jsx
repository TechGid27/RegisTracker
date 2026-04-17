import { createContext, useState, useEffect, useContext } from 'react';
import { authService } from '../api/auth/AuthServices';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedToken = localStorage.getItem('token');
    const savedUser = localStorage.getItem('user');
    
    if (savedToken && savedUser) {
      try {
        setUser(JSON.parse(savedUser));
      } catch (e) {
        localStorage.removeItem('user'); 
      }
    }
    setLoading(false);
  }, []);

  const register = async (userData) => {
    try {
      const data = await authService.register(userData);
      return data; 
    } catch (error) {
      console.error("Registration Error:", error);
      throw error; 
    }
  };

  const verifyEmail = async (payload) => {
    try {
      const data = await authService.verifyEmail(payload);
      return data;
    } catch (error) {
      throw error;
    }
  };

  const resendOtp = async (payload) => {
    try {
      const data = await authService.resendOtp(payload);
      return data;
    } catch (error) {
      throw error;
    }
  };

  const login = async (credentials) => {
    try {
      const data = await authService.login(credentials);
      localStorage.setItem('token', data.token);
      localStorage.setItem('user', JSON.stringify(data.user));
      setUser(data.user);
      return { success: true, user: data.user }; 
    } catch (error) {
      return { success: false, message: error.message };
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, register, verifyEmail, resendOtp, logout, loading }}>
      {!loading && children}
    </AuthContext.Provider>
  );
};

export const UseAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};