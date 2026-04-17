import { request } from './Client'; // Siguroha nga husto ang path

export const metaService = {
  getRequirements: () => request('/DocumentRequirements'),
  getRequirementById: (id) => request(`/DocumentRequirements/${id}`),
  getTypes: () => request('/DocumentTypes'),
  createType: (data) => request('/DocumentTypes', {
    method: 'POST',
    body: data, 
  }),
  getTypeById: (id) => request(`/DocumentTypes/${id}`),
  updateType: (id, data) => request(`/DocumentTypes/${id}`, {
    method: 'PUT',
    body: data, 
  }),
  deleteType: (id) => request(`/DocumentTypes/${id}`, {
    method: 'DELETE',
  }),
};