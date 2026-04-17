import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { metaService } from '../api/metaService'; 

const DocumentTypeContext = createContext();

export const DocumentTypeProvider = ({ children }) => {
  const [documentTypes, setDocumentTypes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);


  const fetchDocumentTypes = useCallback(async () => {
    setLoading(true);
    try {
      const data = await metaService.getTypes();
      setDocumentTypes(data);
      setError(null);
    } catch (err) {
      setError('Failed to load document types');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchDocumentTypes();
  }, [fetchDocumentTypes]);

  // CREATE
  const addDocumentType = async (newData) => {
    try {
      await metaService.createType(newData);
      await fetchDocumentTypes(); 
      return { success: true };
    } catch (err) {
      return { success: false, error: err };
    }
  };

  // UPDATE
  const updateDocumentType = async (id, updatedData) => {
    try {
      await metaService.updateType(id, updatedData);
      await fetchDocumentTypes(); // Refresh list
      return { success: true };
    } catch (err) {
      return { success: false, error: err };
    }
  };

  // DELETE
  const deleteDocumentType = async (id) => {
    try {
      await metaService.deleteType(id);
      setDocumentTypes((prev) => prev.filter((item) => item.id !== id));
      return { success: true };
    } catch (err) {
      return { success: false, error: err };
    }
  };

  return (
    <DocumentTypeContext.Provider
      value={{
        documentTypes,
        loading,
        error,
        fetchDocumentTypes,
        addDocumentType,
        updateDocumentType,
        deleteDocumentType,
      }}
    >
      {children}
    </DocumentTypeContext.Provider>
  );
};

// Custom hook para dali ra gamiton
export const UseDocumentTypes = () => {
  const context = useContext(DocumentTypeContext);
  if (!context) {
    throw new Error('useDocumentTypes must be used within a DocumentTypeProvider');
  }
  return context;
};