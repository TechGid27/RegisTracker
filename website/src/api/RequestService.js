import { request } from './Client';

export const requestService = {
  getAll: () => request('/DocumentRequests?pageSize=100'),
  getById: (id) => request(`/DocumentRequests/${id}`),
  getByUser: (userId) => request(`/DocumentRequests/user/${userId}?pageSize=100`),
  getByReference: (ref) => request(`/DocumentRequests/reference/${ref}`),
  create: (data) => request('/DocumentRequests', { method: 'POST', body: data }),
  update: (id, data) => request(`/DocumentRequests/${id}`, { method: 'PUT', body: data }),
  delete: (id) => request(`/DocumentRequests/${id}`, { method: 'DELETE' }),

  upload: (id, formData) => request(`/DocumentRequests/${id}/upload`, {
    method: 'POST',
    body: formData,
  }),
};