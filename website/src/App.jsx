import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Route, Routes, Navigate } from 'react-router-dom';
import { UseAuth } from './context/AuthContext'; 
import theme from './theme/Theme.jsx'; 

// Layouts & Pages (Import matches your previous code)
import StudentLayout from './views/client/layout/index.jsx';
import AdminLayout from './views/admin/layout/index.jsx';
import Home from './views/public/Home.jsx';
import Requirements from './views/public/Requirements.jsx';
import Announcement from './views/public/Announcement.jsx';
import Login from './views/auth/Login.jsx';
import Signup from './views/auth/Signup.jsx';
import StudentDashboard from './views/client/pages/dashboard.jsx';
import AdminDashboard from './views/admin/pages/dashboard.jsx';
import NewRequest from './views/client/pages/request.jsx';
import PendingRequests from './views/admin/pages/Pending.jsx';
import AnnouncementPost from './components/announcementForm.jsx';
import Announcementpage from './views/admin/pages/announcementpage.jsx';
import Documenttype from './views/admin/pages/documentType.jsx';

// Providers
import { RequestProvider } from './context/RequestContext';
import { MetaProvider } from './context/MetaContext';
import { AnnouncementProvider } from './context/AnnouncementsContext';
import { DocumentTypeProvider } from './context/DocumentTypeContext';
import UpdateRequest from './views/admin/pages/updaterequest.jsx';

export default function App() {
  const { user, loading } = UseAuth(); 

  if (loading) return null; 

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AnnouncementProvider> 
        <MetaProvider>
        <DocumentTypeProvider>
          <RequestProvider> 
            <Routes>
              <Route 
                element={
                  // Kon ang user kay Admin, dili siya pasudlon sa StudentLayout
                  user?.role === 'Admin' 
                    ? <Navigate to="/admin/dashboard" replace /> 
                    : <StudentLayout />
                }
              >
                <Route path="/" element={<Home />} />
                <Route path="/requirements" element={<Requirements />} />
                <Route path="/announcements" element={<Announcement />} />
                
                {/* Private Student Routes */}
                <Route path="/new-request" element={
                  user?.role === 'Student' ? <NewRequest /> : <Navigate to="/login" replace />
                }/>

                <Route path="/dashboard" element={
                  user?.role === 'Student' ? <StudentDashboard /> : <Navigate to="/login" replace />
                } />

                {/* Login/Register Logic */}
                <Route path="/login" element={
                  user 
                    ? <Navigate to={user.role === 'Admin' ? "/admin/dashboard" : "/dashboard"} replace /> 
                    : <Login />
                } />
                <Route path="/register" element={
                  user 
                    ? <Navigate to={user.role === 'Admin' ? "/admin/dashboard" : "/dashboard"} replace /> 
                    : <Signup />
                } />
              </Route>

              {/* 2. ADMIN ROUTES */}
              <Route 
                path="/admin" 
                element={user?.role === 'Admin' ? <AdminLayout /> : <Navigate to="/login" replace />}
              >
                <Route index element={<Navigate to="dashboard" replace />} />
                <Route path="dashboard" element={<AdminDashboard />} /> 
                <Route path="pending" element={<PendingRequests />} />
                <Route path="update" element={ <UpdateRequest/> }/>
                <Route path="announcement-post" element={ <AnnouncementPost/> }/>
                <Route path="announcement-lists" element={ <Announcementpage />}/>
                <Route path="document" element={ <Documenttype /> } />
                <Route path="settings" element={<div>Admin Settings</div>} />
              </Route>

              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </RequestProvider>
          </DocumentTypeProvider>
        </MetaProvider>
      </AnnouncementProvider>
    </ThemeProvider>
  );
}