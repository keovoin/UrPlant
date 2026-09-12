import { useState, useEffect } from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { isAuthenticated, hasApiKey, setApiKey, logout } from './services/api';
import LoginPage from './pages/Login';
import DashboardPage from './pages/Dashboard';
import PlantsPage from './pages/Plants';
import PlantFormPage from './pages/PlantForm';
import UsersPage from './pages/Users';
import UserDetailPage from './pages/UserDetail';
import ReviewUnverifiedPage from './pages/ReviewUnverified';
import ReviewFlaggedPage from './pages/ReviewFlagged';

const navItems = [
  { to: '/', label: 'Dashboard', icon: '📊' },
  { to: '/plants', label: 'Plants', icon: '🌿' },
  { to: '/users', label: 'Users', icon: '👥' },
  { to: '/review/unverified', label: 'Unverified', icon: '🔎' },
  { to: '/review/flagged', label: 'Flagged', icon: '🚩' },
];

export default function App() {
  const [auth, setAuth] = useState(!!isAuthenticated());
  const [apiKeyReady, setApiKeyReady] = useState(hasApiKey());
  const location = useLocation();

  useEffect(() => {
    setAuth(!!isAuthenticated());
  }, [location.pathname]);

  if (!apiKeyReady) {
    return <SetupPage onDone={() => setApiKeyReady(true)} />;
  }

  if (!auth) {
    return <LoginPage onLogin={() => setAuth(true)} />;
  }

  return (
    <div className="flex h-screen" style={{ background: 'var(--canvas)' }}>
      <aside className="w-60 flex flex-col shrink-0 text-white" style={{ background: 'linear-gradient(180deg,#0F3D20 0%,#12582B 100%)' }}>
        <div className="px-5 py-5 flex items-center gap-2.5 border-b border-white/10">
          <span className="w-9 h-9 rounded-xl grid place-items-center text-lg" style={{ background: 'rgba(255,255,255,.14)' }}>🌿</span>
          <div>
            <div className="text-base font-black tracking-tight leading-tight">UrPlant</div>
            <div className="text-[10px] font-bold tracking-widest uppercase opacity-60">Admin</div>
          </div>
        </div>
        <nav className="flex-1 py-3 px-3 space-y-1">
          {navItems.map(({ to, label, icon }) => {
            const active = to === '/' ? location.pathname === '/' : location.pathname.startsWith(to);
            return (
              <a key={to} href={to}
                className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-bold transition-all ${
                  active ? 'bg-white/15 text-white shadow-[inset_0_0_0_1.5px_rgba(244,168,44,.6)]' : 'text-green-100/70 hover:bg-white/8 hover:text-white'
                }`}>
                <span className="text-base">{icon}</span>{label}
              </a>
            );
          })}
        </nav>
        <div className="p-4 border-t border-white/10">
          <button onClick={() => { logout(); setAuth(false); window.location.href = '/'; }}
            className="text-xs font-bold text-green-100/60 hover:text-white transition-colors">
            ⎋ Sign out
          </button>
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
    <div className="flex min-h-screen items-center justify-center" style={{ background: 'var(--canvas)' }}>
      <div className="w-full max-w-sm card shadow-card p-8 rise">
        <div className="text-center mb-6">
          <span className="w-14 h-14 mx-auto grid place-items-center text-3xl rounded-2xl" style={{ background: 'var(--leaf-soft)' }}>🌿</span>
          <h1 className="text-2xl font-black mt-3" style={{ color: 'var(--ink)' }}>UrPlant Admin</h1>
          <p className="text-sm font-semibold mt-1.5" style={{ color: 'var(--ink-faint)' }}>Enter your Firebase Web API Key to start</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <input
            type="text"
            placeholder="Firebase Web API Key"
            value={key}
            onChange={e => setKey(e.target.value)}
            className="input"
            required
          />
          <p className="text-xs leading-relaxed" style={{ color: 'var(--ink-faint)' }}>
            Firebase Console → Project Settings → General → Web app → apiKey
          </p>
          <button type="submit" className="btn-chunky w-full h-12 text-base">
            Continue
          </button>
        </form>
      </div>
    </div>
  );
}
