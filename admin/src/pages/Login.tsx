import { useState, FormEvent } from 'react';
import { login } from '../services/api';
import toast from 'react-hot-toast';

export default function LoginPage({ onLogin }: { onLogin: () => void }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      await login(email, password);
      onLogin();
      window.location.href = '/';
    } catch (err: any) {
      const msg = err?.response?.data?.error?.message || err.message || 'Login failed';
      toast.error(msg);
      console.error('Login error:', err);
    }
    setLoading(false);
  }

  return (
    <div className="flex min-h-screen items-center justify-center" style={{ background: 'var(--canvas)' }}>
      <div className="w-full max-w-sm card shadow-card p-8 rise">
        <div className="text-center mb-6">
          <span className="w-14 h-14 mx-auto grid place-items-center text-3xl rounded-2xl" style={{ background: 'var(--leaf-soft)' }}>🌿</span>
          <h1 className="text-2xl font-black mt-3" style={{ color: 'var(--ink)' }}>UrPlant Admin</h1>
          <p className="text-sm font-semibold mt-1.5" style={{ color: 'var(--ink-faint)' }}>Sign in with your admin account</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-3.5">
          <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)}
            className="input" required autoComplete="username" />
          <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)}
            className="input" required autoComplete="current-password" />
          <button type="submit" disabled={loading} className="btn-chunky w-full h-12 text-base disabled:opacity-50">
            {loading ? 'Signing in…' : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
}
