import { useState, useEffect } from 'react';
import { Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import { isAuthenticated, hasApiKey, setApiKey, logout } from './services/api';
import LoginPage from './pages/Login';
import DashboardPage from './pages/Dashboard';
import PlantsPage from './pages/Plants';
import PlantFormPage from './pages/PlantForm';
import UsersPage from './pages/Users';
import UserDetailPage from './pages/UserDetail';
import ReviewUnverifiedPage from './pages/ReviewUnverified';
import ReviewFlaggedPage from './pages/ReviewFlagged';

export default function App() {
  const [auth, setAuth] = useState(!!isAuthenticated());
  const [apiKeyReady, setApiKeyReady] = useState(hasApiKey());

  useEffect(() => {
    setAuth(!!isAuthenticated());
  }, [window.location.pathname]);

  if (!apiKeyReady) {
    return <SetupPage onDone={() => setApiKeyReady(true)} />;
  }

  if (!auth) {
    return <LoginPage onLogin={() => setAuth(true)} />;
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <aside className="w-56 bg-primary-dark text-white flex flex-col">
        <div className="p-4 text-xl font-bold border-b border-green-900">🌿 UrPlant Admin</div>
        <nav className="flex-1 py-2">
          <a href="/" className="block px-4 py-2 text-sm text-green-200 hover:bg-green-800">Dashboard</a>
          <a href="/plants" className="block px-4 py-2 text-sm text-green-200 hover:bg-green-800">Plants</a>
          <a href="/users" className="block px-4 py-2 text-sm text-green-200 hover:bg-green-800">Users</a>
          <a href="/review/unverified" className="block px-4 py-2 text-sm text-green-200 hover:bg-green-800">Unverified</a>
          <a href="/review/flagged" className="block px-4 py-2 text-sm text-green-200 hover:bg-green-800">Flagged</a>
        </nav>
        <div className="p-4 border-t border-green-900 text-sm">
          <button onClick={() => { logout(); setAuth(false); window.location.href = '/'; }} className="text-green-300 hover:text-white">Logout</button>
        </div>
      </aside>
      <main className="flex-1 overflow-auto">
        <Routes>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/plants" element={<PlantsPage />} />
          <Route path="/plants/new" element={<PlantFormPage />} />
          <Route path="/plants/:id/edit" element={<PlantFormPage />} />
          <Route path="/users" element={<UsersPage />} />
          <Route path="/users/:id" element={<UserDetailPage />} />
          <Route path="/review/unverified" element={<ReviewUnverifiedPage />} />
          <Route path="/review/flagged" element={<ReviewFlaggedPage />} />
          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </main>
    </div>
  );
}

function SetupPage({ onDone }: { onDone: () => void }) {
  const [key, setKey] = useState('');

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setApiKey(key.trim());
    onDone();
    window.location.reload();
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50">
      <div className="w-full max-w-sm bg-white rounded-2xl shadow-lg p-8">
        <div className="text-center mb-6">
          <span className="text-4xl">🌿</span>
          <h1 className="text-2xl font-bold text-primary mt-2">UrPlant Admin</h1>
          <p className="text-sm text-gray-500 mt-2">Enter your Firebase Web API Key to start</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <input
            type="text"
            placeholder="Firebase Web API Key"
            value={key}
            onChange={e => setKey(e.target.value)}
            className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-light text-sm"
            required
          />
          <p className="text-xs text-gray-400">
            Find it in Firebase Console → Project Settings → General → Web app → apiKey
          </p>
          <button type="submit" className="w-full py-3 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark">
            Continue
          </button>
        </form>
      </div>
    </div>
  );
}