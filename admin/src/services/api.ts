/**
 * API Service — Auth using Firebase Auth REST API (no SDK needed).
 *
 * To get your Web API Key:
 * 1. Go to https://console.firebase.google.com/project/urplant-app/settings/general
 * 2. Scroll to "Your apps" → "Web app" → copy the "apiKey" from the config
 * 3. Paste it when prompted (stored in localStorage, never committed)
 */

import axios from 'axios';

const API_BASE = 'https://us-central1-urplant-app.cloudfunctions.net/adminApi';

const AUTH_PREFIX = 'Bearer '; // auth header scheme

// Get stored token
function getToken(): string | null {
  return localStorage.getItem('urplant_admin_token');
}
function setToken(token: string) {
  localStorage.setItem('urplant_admin_token', token);
}
function clearToken() {
  localStorage.removeItem('urplant_admin_token');
}

// Get stored API key
function getApiKey(): string {
  return localStorage.getItem('urplant_api_key') || '';
}
export function setApiKey(key: string) {
  localStorage.setItem('urplant_api_key', key);
}
export function hasApiKey(): boolean {
  return !!getApiKey();
}

export function isAuthenticated(): boolean {
  return !!getToken();
}

export async function login(email: string, password: string): Promise<void> {
  const apiKey = getApiKey();
  if (!apiKey) throw new Error('API key not set');

  // Sign in via Firebase Auth REST API
  const res = await axios.post(
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=' + apiKey,
    { email, password, returnSecureToken: true }
  );

  const idToken = res.data.idToken;

  // Verify this user has admin claim by decoding the token
  const payload = JSON.parse(atob(idToken.split('.')[1]));
  if (!payload.admin) {
    throw new Error('This account does not have admin access. Admin claim is not set.');
  }

  setToken(idToken);
  localStorage.setItem('urplant_admin_refresh', res.data.refreshToken);
}

export function logout() {
  clearToken();
  localStorage.removeItem('urplant_admin_refresh');
}

// Firebase ID tokens expire after ~1h. Refresh via stored refreshToken.
async function tryRefreshToken(): Promise<boolean> {
  const rt = localStorage.getItem('urplant_admin_refresh');
  const apiKey = getApiKey();
  if (!rt || !apiKey) return false;
  try {
    const res = await axios.post(
      'https://securetoken.googleapis.com/v1/token?key=' + apiKey,
      { grant_type: 'refresh_token', refresh_token: rt }
    );
    setToken(res.data.id_token);
    localStorage.setItem('urplant_admin_refresh', res.data.refresh_token);
    return true;
  } catch {
    localStorage.removeItem('urplant_admin_refresh');
    return false;
  }
}

function tokenSecondsLeft(): number {
  try {
    const t = getToken();
    if (!t) return 0;
    const p = JSON.parse(atob(t.split('.')[1]));
    return Math.max(0, (p.exp || 0) - Math.floor(Date.now() / 1000));
  } catch { return 0; }
}

// Proactive refresh while the tab is open (keeps long admin sessions alive).
setInterval(() => { if (getToken() && tokenSecondsLeft() < 300) tryRefreshToken(); }, 60_000);

async function request(action: string, payload: any = {}) {
  const token = getToken();
  if (!token) throw new Error('Not authenticated');

  const headers = { Authorization: AUTH_PREFIX + token };
  try {
    const res = await axios.post(API_BASE, { action, payload }, { headers });
    return res.data;
  } catch (err: any) {
    // 401 = expired token → refresh once, retry; else bounce to login
    if (err?.response?.status === 401) {
      const refreshed = await tryRefreshToken();
      if (refreshed) {
        const res = await axios.post(API_BASE, { action, payload }, {
          headers: { Authorization: AUTH_PREFIX + getToken() },
        });
        return res.data;
      }
      logout();
      throw new Error('Session expired — sign in again');
    }
    throw err;
  }
}

export const plantsApi = {
  list: (params?: any) => request('listPlants', params || {}),
  get: (plantId: string) => request('getPlant', { plant_id: plantId }),
  create: (data: any) => request('createPlant', data),
  update: (plantId: string, data: any) => request('updatePlant', { plant_id: plantId, ...data }),
  delete: (plantId: string) => request('deletePlant', { plant_id: plantId }),
};

export const usersApi = {
  list: (params?: any) => request('listUsers', params || {}),
  detail: (userId: string) => request('getUserDetail', { user_id: userId }),
  ban: (userId: string, reason: string) => request('banUser', { user_id: userId, reason }),
};

export const reviewApi = {
  unverified: (params?: any) => request('listUnverified', params || {}),
  reviewUnverified: (id: string, action: string, plantData?: any) =>
    request('reviewUnverified', { unverified_id: id, action, plant_data: plantData }),
  flagged: (params?: any) => request('listFlagged', params || {}),
  reviewFlagged: (id: string, action: string) => request('reviewFlaggedPhoto', { flagged_id: id, action }),
};

export const analyticsApi = {
  get: (metric: string) => request('getAnalytics', { metric }),
};
