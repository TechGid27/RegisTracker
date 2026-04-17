import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1a237e',  
      buttons: '#8089E6',
    },
    secondary: {
      main: '#dc004e',
    },
 
    background: {
      default: '#f4f6f8', 
      
    },
  },

  components: {
    MuiAppBar: {
      styleOverrides: {
        root: {
          boxShadow: 'none', 
          borderBottom: '1px solid rgba(0, 0, 0, 0.12)',
        },
      },
    },
  },
});

export default theme; 