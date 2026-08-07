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
    <div className="flex min-h-screen items-center justify-center bg-gray-50">
      <div className="w-full max-w-sm bg-white rounded-2xl shadow-lg p-8">
        <div className="text-center mb-6">
          <span className="text-4xl">🌿</span>
          <h1 className="text-2xl font-bold text-primary mt-2">UrPlant Admin</h1>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)}
            className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-light" required />
          <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)}
            className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-light" required />
          <button type="submit" disabled={loading}
            className="w-full py-3 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark disabled:opacity-50">
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
}