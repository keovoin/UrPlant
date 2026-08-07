import { useState, useEffect } from 'react';
import { analyticsApi, plantsApi } from '../services/api';
import { Users, Camera, Leaf, AlertTriangle } from 'lucide-react';

export default function DashboardPage() {
  const [stats, setStats] = useState({ users: 0, scans: 0, plants: 0, pending: 0 });
  const [popular, setPopular] = useState<any[]>([]);

  useEffect(() => {
    (async () => {
      try {
        const [usersR, scansR, plantsR, pendingR] = await Promise.all([
          analyticsApi.get('total_users'),
          analyticsApi.get('total_scans'),
          analyticsApi.get('total_plants'),
          analyticsApi.get('pending_reviews'),
        ]);
        setStats({ users: usersR.value, scans: scansR.value, plants: plantsR.value, pending: pendingR.value });
        const plants = await plantsApi.list({ page_size: 5, sort: 'total_unlocks' });
        setPopular(plants.plants || []);
      } catch {}
    })();
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Dashboard</h1>
      <div className="grid grid-cols-4 gap-4 mb-8">
        <StatCard icon={<Users />} label="Users" value={stats.users} />
        <StatCard icon={<Camera />} label="Scans" value={stats.scans} />
        <StatCard icon={<Leaf />} label="Plants" value={stats.plants} />
        <StatCard icon={<AlertTriangle />} label="Pending" value={stats.pending} color="text-amber-500" />
      </div>
      <div className="bg-white rounded-xl shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Popular Plants</h2>
        <table className="w-full text-sm">
          <thead><tr className="text-left text-gray-500"><th>Plant</th><th>Rarity</th><th>Unlocks</th></tr></thead>
          <tbody>
            {popular.map((p: any) => (
              <tr key={p.id} className="border-t">
                <td className="py-2">{p.name_en || p.scientific_name}</td>
                <td><RarityBadge rarity={p.rarity} /></td>
                <td>{p.total_unlocks || 0}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function StatCard({ icon, label, value, color = 'text-primary' }: any) {
  return (
    <div className="bg-white rounded-xl shadow p-4 flex items-center gap-3">
      <div className={`${color}`}>{icon}</div>
      <div><p className="text-2xl font-bold">{value}</p><p className="text-xs text-gray-500">{label}</p></div>
    </div>
  );
}

export function RarityBadge({ rarity }: { rarity: string }) {
  const map: any = { normal: { bg: 'bg-green-100', text: 'text-green-700', label: 'Normal' }, rare: { bg: 'bg-blue-100', text: 'text-blue-700', label: 'Rare' }, special_rare: { bg: 'bg-yellow-100', text: 'text-yellow-700', label: 'Special Rare' } };
  const s = map[rarity] || map.normal;
  return <span className={`text-xs px-2 py-0.5 rounded-full ${s.bg} ${s.text}`}>{s.label}</span>;
}