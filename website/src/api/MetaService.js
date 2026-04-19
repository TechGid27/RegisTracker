import { request } from './Client';

export const metaService = {
  getRequirements: () => request('/DocumentRequirements'),
  getRequirementById: (id) => request(`/DocumentRequirements/${id}`),
  getRequirementsByType: (typeId) => request(`/DocumentRequirements/type/${typeId}`),
  createRequirement: (data) => request('/DocumentRequirements', { method: 'POST', body: data }),
  updateRequirement: (id, data) => request(`/DocumentRequirements/${id}`, { method: 'PUT', body: data }),
  deleteRequirement: (id) => request(`/DocumentRequirements/${id}`, { method: 'DELETE' }),
  getTypes: () => request('/DocumentTypes'),
  createType: (data) => request('/DocumentTypes', { method: 'POST', body: data }),
  getTypeById: (id) => request(`/DocumentTypes/${id}`),
  updateType: (id, data) => request(`/DocumentTypes/${id}`, { method: 'PUT', body: data }),
  deleteType: (id) => request(`/DocumentTypes/${id}`, { method: 'DELETE' }),
};