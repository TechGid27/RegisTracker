const BASE_URL = 'http://localhost:5097/api';

export const request = async (endpoint, options = {}) => {
  const { body, ...customConfig } = options;
  
  const token = localStorage.getItem('token');

  // 1. I-check kon ang body kay FormData (File upload)
  const isFormData = body instanceof FormData;

  const headers = isFormData ? {} : { 'Content-Type': 'application/json' };
  
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const config = {
    method: body ? 'POST' : 'GET',
    ...customConfig,
    headers: {
      ...headers,
      ...customConfig.headers,
    },
  };

  // 3. I-stringify lang kon DILI FormData
  if (body) {
    config.body = isFormData ? body : JSON.stringify(body);
  }

  const response = await fetch(`${BASE_URL}${endpoint}`, config);
  
  if (response.status === 401) {
    localStorage.removeItem('token'); 
    window.location.href = '/login';
    throw new Error('Session expired. Please login again.');
  }

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    
    let errorMessage = "Something went wrong";
    if (errorData.errors) {
      errorMessage = Object.values(errorData.errors).flat().join(", ");
    } else if (errorData.title) {
      errorMessage = errorData.title;
    }

    throw new Error(errorMessage);
  }

  return response.status === 204 ? null : response.json();
};