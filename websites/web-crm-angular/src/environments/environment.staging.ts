export const environment = {
  production: false,
  staging: true,

  // Base URLs
  baseUrl: 'https://crm.rasha.local/',

  // API Services — SSR (server-side) uses Docker service names directly
  apiUrl: '',
  coreApiUrl: 'http://rasha-svc-core-laravel:8400/api',
  crmApiUrl: 'http://rasha-svc-crm-laravel:8402/api',
  dynamicFormApiUrl: 'http://rasha-svc-dynamic-form-laravel:8403/api',
  erpApiUrl: 'http://rasha-svc-erp-laravel:8404/api',
};
