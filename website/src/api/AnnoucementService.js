import { request } from './Client';

export const AnnouncementService = {
  getAll: () => request('/Announcements'),
  getById: (id) => request(`/Announcements/${id}`),
  create: (data) => request('/Announcements', { method: 'POST', body: data }),
  update: (id, data) => request(`/Announcements/${id}`, { method: 'PUT', body: data }),
  delete: (id) => request(`/Announcements/${id}`, { method: 'DELETE' }),
};