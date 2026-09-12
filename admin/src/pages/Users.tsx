import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { usersApi } from '../services/api';
import toast from 'react-hot-toast';

export default function UsersPage() {
  const [users, setUsers] = useState<any[]>([]);
  const [search, setSearch] = useState('');

  useEffect(() => { loadUsers(); }, []);
  async function loadUsers() {
    try {
      const res = await usersApi.list({ page_size: 100 });
      setUsers(res.users || []);
    } catch { toast.error('Failed to load users'); }
  }

  const filtered = users.filter((u: any) => {
    if (!search) return true;
    const s = search.toLowerCase();
    return (u.display_name || '').toLowerCase().includes(s) || (u.email || '').toLowerCase().includes(s);
  });

  return (
    <div className="page-pad">
      <div className="flex items-end justify-between mb-6 rise">
        <div>
          <p className="text-xs font-extrabold uppercase tracking-widest" style={{ color: 'var(--ink-faint)' }}>UrPlant · community</p>
          <h1 className="text-3xl font-black tracking-tight mt-1" style={{ color: 'var(--ink)' }}>Explorers</h1>
        </div>
        <input placeholder="🔍 Search name or email…" value={search} onChange={e => setSearch(e.target.value)}
          className="input h-10 !w-72" />
      </div>

      <div className="card shadow-card p-0 overflow-hidden rise rise-1">
        <table className="w-full">
          <thead>
            <tr className="border-b" style={{ background: '#F1F8F1', borderColor: 'var(--line)' }}>
              <th className="th">Explorer</th><th className="th">Email</th><th className="th">Lang</th>
              <th className="th text-right">Plants</th><th className="th text-right">Scans</th><th className="th text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((u: any) => (
              <tr key={u.id} className="border-b row-hover" style={{ borderColor: 'var(--line)' }}>
                <td className="td font-extrabold" style={{ color: 'var(--ink)' }}>
                  <span className="inline-flex items-center gap-2">
                    <span className="w-7 h-7 rounded-full grid place-items-center text-xs font-black" style={{ background: 'var(--leaf-soft)', color: 'var(--leaf-dark)' }}>
                      {(u.display_name || '?').slice(0, 1).toUpperCase()}
                    </span>
                    {u.display_name || '—'}
                  </span>
                </td>
                <td className="td">{u.email || '—'}</td>
                <td className="td"><span className={`pill ${u.language === 'km' ? 'pill-gold' : 'pill-gray'}`}>{u.language || 'en'}</span></td>
                <td className="td text-right font-black" style={{ color: 'var(--leaf)' }}>{u.plants_unlocked || 0}</td>
                <td className="td text-right">{u.total_scans || 0}</td>
                <td className="td text-right whitespace-nowrap">
                  <Link to={`/users/${u.id}`} className="btn-quiet h-7 !px-2.5 text-[11px] mr-1.5 !inline-flex !align-middle">View</Link>
                  <button onClick={async () => { if (confirm(`Ban ${u.display_name || u.email}?`)) { try { await usersApi.ban(u.id, 'Admin action'); toast.success('User banned'); loadUsers(); } catch { toast.error('Ban failed'); } } }}
                    className="btn-danger h-7 !px-2.5 text-[11px] !inline-flex !align-middle">Ban</button>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr><td colSpan={6} className="td text-center py-10" style={{ color: 'var(--ink-faint)' }}>No explorers found.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
