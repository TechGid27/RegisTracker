import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Route, Routes, Navigate } from 'react-router-dom';
import { UseAuth } from './context/AuthContext';
import theme from './theme/Theme.jsx';

// Layouts
import StudentLayout from './views/client/layout/index.jsx';
import AdminLayout from './views/admin/layout/index.jsx';

// Public pages
import Home from './views/public/Home.jsx';
import Requirements from './views/public/Requirements.jsx';
import Announcement from './views/public/Announcement.jsx';

// Auth pages
import Login from './views/auth/Login.jsx';
import Signup from './views/auth/Signup.jsx';
import ForgotPassword from './views/auth/ForgotPassword.jsx';

// Student pages
import StudentDashboard from './views/client/pages/dashboard.jsx';
import NewRequest from './views/client/pages/request.jsx';
import ProfilePage from './views/client/pages/profile.jsx';

// Admin / Staff pages
import AdminDashboard from './views/admin/pages/dashboard.jsx';
import StaffDashboard from './views/admin/pages/staff_dashboard.jsx';
import PendingRequests from './views/admin/pages/Pending.jsx';
import UpdateRequest from './views/admin/pages/updaterequest.jsx';
import Announcementpage from './views/admin/pages/announcementpage.jsx';
import Documenttype from './views/admin/pages/documentType.jsx';
import RequirementsPage from './views/admin/pages/requirements.jsx';

// Providers
import { RequestProvider } from './context/RequestContext';
import { MetaProvider } from './context/MetaContext';
import { AnnouncementProvider } from './context/AnnouncementsContext';
import { DocumentTypeProvider } from './context/DocumentTypeContext';

// Helper: redirect logged-in users to their home
function HomeRedirect({ user }) {
  if (!user) return null;
  if (user.role === 'Admin') return <Navigate to="/admin/dashboard" replace />;
  if (user.role === 'Staff') return <Navigate to="/staff/dashboard" replace />;
  return <Navigate to="/dashboard" replace />;
}

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

                {/* ── PUBLIC + STUDENT ROUTES ── */}
                <Route
                  element={
                    user?.role === 'Admin' ? <Navigate to="/admin/dashboard" replace /> :
                    user?.role === 'Staff' ? <Navigate to="/staff/dashboard" replace /> :
                    <StudentLayout />
                  }
                >
                  <Route path="/" element={<Home />} />
                  <Route path="/requirements" element={<Requirements />} />
                  <Route path="/announcements" element={<Announcement />} />

                  <Route path="/dashboard" element={
                    user?.role === 'Student' ? <StudentDashboard /> : <Navigate to="/login" replace />
                  } />
                  <Route path="/new-request" element={
                    user?.role === 'Student' ? <NewRequest /> : <Navigate to="/login" replace />
                  } />
                  <Route path="/profile" element={
                    user?.role === 'Student' ? <ProfilePage /> : <Navigate to="/login" replace />
                  } />

                  <Route path="/login" element={
                    user ? <HomeRedirect user={user} /> : <Login />
                  } />
                  <Route path="/register" element={
                    user ? <HomeRedirect user={user} /> : <Signup />
                  } />
                  <Route path="/forgot-password" element={
                    user ? <HomeRedirect user={user} /> : <ForgotPassword />
                  } />
                </Route>

                {/* ── ADMIN ROUTES ── */}
                <Route
                  path="/admin"
                  element={user?.role === 'Admin' ? <AdminLayout /> : <Navigate to="/login" replace />}
                >
                  <Route index element={<Navigate to="dashboard" replace />} />
                  <Route path="dashboard"          element={<AdminDashboard />} />
                  <Route path="pending"            element={<PendingRequests />} />
                  <Route path="update"             element={<UpdateRequest />} />
                  <Route path="announcement-lists" element={<Announcementpage />} />
                  <Route path="document"           element={<Documenttype />} />
                  <Route path="requirements"       element={<RequirementsPage />} />
                </Route>

                {/* ── STAFF ROUTES ── */}
                <Route
                  path="/staff"
                  element={user?.role === 'Staff' ? <AdminLayout /> : <Navigate to="/login" replace />}
                >
                  <Route index element={<Navigate to="dashboard" replace />} />
                  <Route path="dashboard" element={<StaffDashboard />} />
                  <Route path="pending"   element={<PendingRequests />} />
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
