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
      const res = await usersApi.list({ page_size: 50 });
      setUsers(res.users || []);
    } catch { toast.error('Failed to load users'); }
  }

  const filtered = users.filter((u: any) => {
    if (!search) return true;
    const s = search.toLowerCase();
    return (u.display_name || '').toLowerCase().includes(s) || (u.email || '').toLowerCase().includes(s);
  });

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Users</h1>
      <input placeholder="Search..." value={search} onChange={e => setSearch(e.target.value)} className="px-3 py-2 border rounded-lg w-64 text-sm mb-4" />
      <div className="bg-white rounded-xl shadow overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-gray-500 bg-gray-50">
              <th className="p-3">User</th><th className="p-3">Email</th><th className="p-3">Lang</th><th className="p-3">Plants</th><th className="p-3">Scans</th><th className="p-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((u: any) => (
              <tr key={u.id} className="border-t">
                <td className="p-3">{u.display_name || '-'}</td>
                <td className="p-3 text-gray-500">{u.email}</td>
                <td className="p-3">{u.language || 'en'}</td>
                <td className="p-3">{u.plants_unlocked || 0}</td>
                <td className="p-3">{u.total_scans || 0}</td>
                <td className="p-3">
                  <Link to={`/users/${u.id}`} className="text-primary text-xs hover:underline mr-3">View</Link>
                  <button onClick={async () => { if (confirm('Ban user?')) { await usersApi.ban(u.id, 'Admin action'); toast.success('User banned'); loadUsers(); } }} className="text-red-500 text-xs hover:underline">Ban</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}