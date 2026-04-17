import { createContext, useContext, useState, useCallback, useEffect, useRef } from 'react';
import { AnnouncementService } from '../api/AnnoucementService';

const AnnouncementContext = createContext();

const CACHE_DURATION = 5 * 60 * 1000;

export const AnnouncementProvider = ({ children }) => {
  const [announcements, setAnnouncements] = useState([]); 
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  const lastFetched = useRef(0);

  const loadMetadata = useCallback(async (forceRefresh = false) => {
    const now = Date.now();
    
    if (!forceRefresh && (now - lastFetched.current < CACHE_DURATION) && announcements.length > 0) {
      return;
    }

    setLoading(true);
    try {
    
      const annData = await AnnouncementService.getAll();
 
      setAnnouncements(annData || []);
      
      lastFetched.current = now; 
      setError(null);
    } catch (err) {
      console.error("Failed to fetch announcements:", err);
      setError("Dili makuha ang data gikan sa server.");
    } finally {
      setLoading(false);
    }
  }, [announcements.length]);

  useEffect(() => {
    loadMetadata();
  }, [loadMetadata]);

  return (
    <AnnouncementContext.Provider value={{ 
      announcements,
      loading, 
      error, 
      refreshMetadata: () => loadMetadata(true) 
    }}>
      {children}
    </AnnouncementContext.Provider>
  );
};

export const UseAnnouncements = () => {
  const context = useContext(AnnouncementContext);
  if (!context) {
    throw new Error('useAnnouncements must be used within an AnnouncementProvider');
  }
  return context;
};