import { request } from './Client';

export const requestService = {
  getAll: () => request('/DocumentRequests'),
  getById: (id) => request(`/DocumentRequests/${id}`),
  getByUser: (userId) => request(`/DocumentRequests/user/${userId}`),
  getByReference: (ref) => request(`/DocumentRequests/reference/${ref}`),
  create: (data) => request('/DocumentRequests', { method: 'POST', body: data }),
  update: (id, data) => request(`/DocumentRequests/${id}`, { method: 'PUT', body: data }),
  delete: (id) => request(`/DocumentRequests/${id}`, { method: 'DELETE' }),

  upload: (id, formData) => request(`/DocumentRequests/${id}/upload`, {
    method: 'POST',
    body: formData,
  }),
  download: (id) => request(`/DocumentRequests/${id}/download`, {
    method: 'GET',
  }),
};