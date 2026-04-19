import { request } from './Client';

export const userService = {
  getById: (id) => request(`/Users/${id}`),
  update: (id, data) => request(`/Users/${id}`, { method: 'PUT', body: data }),
};
