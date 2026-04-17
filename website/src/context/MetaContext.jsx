import { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { metaService } from '../api/metaService';

const MetaContext = createContext();

export const MetaProvider = ({ children }) => {
  const [documentTypes, setDocumentTypes] = useState([]);
  const [requirements, setRequirements] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const loadMetadata = useCallback(async () => {
    setLoading(true);
    try {
      const [typesData, reqsData] = await Promise.all([
        metaService.getTypes(),
        metaService.getRequirements(),
      ]);
      
      setDocumentTypes(typesData);
      setRequirements(reqsData);
      setError(null);
    } catch (err) {
      console.error("Failed to fetch metadata:", err);
      setError("Dili makuha ang data gikan sa server.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadMetadata();
  }, [loadMetadata]);

  return (
    <MetaContext.Provider value={{ 
      documentTypes, 
      requirements, 
      loading, 
      error, 
      refreshMetadata: loadMetadata 
    }}>
      {children}
    </MetaContext.Provider>
  );
};

export const UseMeta = () => {
  const context = useContext(MetaContext);
  if (!context) {
    throw new Error('useMeta must be used within a MetaProvider');
  }
  return context;
};