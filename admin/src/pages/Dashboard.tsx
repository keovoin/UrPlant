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
        const plants = await plantsApi.list({ page_size: 8, sort: 'total_unlocks' });
        setPopular(plants.plants || []);
      } catch {}
    })();
  }, []);

  return (
    <div className="page-pad">
      <div className="flex items-end justify-between mb-6 rise">
        <div>
          <p className="text-xs font-extrabold uppercase tracking-widest" style={{ color: 'var(--ink-faint)' }}>UrPlant · overview</p>
          <h1 className="text-3xl font-black tracking-tight mt-1" style={{ color: 'var(--ink)' }}>Dashboard</h1>
        </div>
        <button className="btn-quiet" onClick={() => window.location.reload()}>↻ Refresh</button>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard className="rise-1" icon={<Users size={20} />} label="Users" value={stats.users} bg="#D8F0DC" fg="#12582B" />
        <StatCard className="rise-2" icon={<Camera size={20} />} label="Scans" value={stats.scans} bg="#DDEBFD" fg="#1B5BAE" />
        <StatCard className="rise-3" icon={<Leaf size={20} />} label="Species" value={stats.plants} bg="#EAE2FE" fg="#5B32CC" />
        <StatCard className="rise-4" icon={<AlertTriangle size={20} />} label="Pending review" value={stats.pending} bg="#FBEEDA" fg="#C77F0E" />
      </div>

      <div className="card shadow-card rise rise-3">
        <div className="flex items-center justify-between mb-4">
          <h2 className="section-title">🏆 Most discovered</h2>
          <a href="/plants" className="text-xs font-extrabold" style={{ color: 'var(--leaf)' }}>All plants →</a>
        </div>
        <table className="w-full">
          <thead><tr className="border-b" style={{ borderColor: 'var(--line)' }}>
            <th className="th">Plant</th><th className="th">Rarity</th><th className="th text-right">Unlocks</th>
          </tr></thead>
          <tbody>
            {popular.map((p: any) => (
              <tr key={p.id} className="border-b row-hover" style={{ borderColor: 'var(--line)' }}>
                <td className="td font-bold" style={{ color: 'var(--ink)' }}>{p.name_en || p.scientific_name}</td>
                <td className="td"><RarityBadge rarity={p.rarity} /></td>
                <td className="td text-right font-black" style={{ color: 'var(--gold-edge)' }}>{p.total_unlocks || 0}</td>
              </tr>
            ))}
            {popular.length === 0 && (
              <tr><td colSpan={3} className="td text-center py-8" style={{ color: 'var(--ink-faint)' }}>No data yet — scans will populate this.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function StatCard({ icon, label, value, bg, fg, className = '' }: any) {
  return (
    <div className={`card flex items-center gap-3.5 ${className}`}>
      <span className="w-11 h-11 rounded-2xl grid place-items-center shrink-0" style={{ background: bg, color: fg }}>{icon}</span>
      <div>
        <p className="text-2xl font-black leading-none" style={{ color: 'var(--ink)' }}>{value.toLocaleString()}</p>
        <p className="text-[11px] font-extrabold uppercase tracking-wide mt-1" style={{ color: 'var(--ink-faint)' }}>{label}</p>
      </div>
    </div>
  );
}

export function RarityBadge({ rarity }: { rarity: string }) {
  const map: Record<string, { cls: string; label: string }> = {
    normal: { cls: 'pill-green', label: '★ Normal' },
    rare: { cls: 'pill-blue', label: '✦ Rare' },
    special_rare: { cls: 'pill-gold', label: '✦✦ Special' },
  };
  const s = map[rarity] || map.normal;
  return <span className={`pill ${s.cls}`}>{s.label}</span>;
}
