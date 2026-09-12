import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { usersApi } from '../services/api';
import { RarityBadge } from './Dashboard';
import toast from 'react-hot-toast';

export default function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [user, setUser] = useState<any>(null);
  const [plants, setPlants] = useState<any[]>([]);

  useEffect(() => {
    if (id) loadUser();
  }, [id]);

  async function loadUser() {
    try {
      const res = await usersApi.detail(id!);
      setUser(res.user);
      setPlants(res.plants || []);
    } catch { toast.error('Failed to load user'); }
  }

  if (!user) return <div className="page-pad"><p className="font-bold" style={{ color: 'var(--ink-faint)' }}>Loading…</p></div>;

  const xp = user.total_xp || 0;
  const level = user.level || 1;
  const base = (level - 1) * (level - 1) * 100;
  const nextXp = level * level * 100;
  const pct = Math.max(0, Math.min(100, Math.round(((xp - base) / (nextXp - base)) * 100)));

  const fmt = (t: any) => {
    const sec = t?._seconds ?? t?.seconds ?? (typeof t === 'number' ? t : null);
    return sec ? new Date(sec * 1000).toLocaleDateString() : '—';
  };

  return (
    <div className="page-pad">
      <div className="flex items-center gap-4 mb-6 rise">
        <span className="w-14 h-14 rounded-2xl grid place-items-center text-2xl font-black" style={{ background: 'var(--leaf-soft)', color: 'var(--leaf-dark)' }}>
          {(user.display_name || user.email || '?').slice(0, 1).toUpperCase()}
        </span>
        <div>
          <p className="text-xs font-extrabold uppercase tracking-widest" style={{ color: 'var(--ink-faint)' }}>Explorer</p>
          <h1 className="text-2xl font-black tracking-tight" style={{ color: 'var(--ink)' }}>{user.display_name || user.email}</h1>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-5">
        <div className="card shadow-card p-5 rise rise-1">
          <h2 className="section-title mb-3">Profile</h2>
          <dl className="text-sm space-y-1.5" style={{ color: 'var(--ink-soft)' }}>
            <div className="flex justify-between"><dt className="font-bold">Email</dt><dd>{user.email || '—'}</dd></div>
            <div className="flex justify-between"><dt className="font-bold">Language</dt><dd><span className={`pill ${user.language === 'km' ? 'pill-gold' : 'pill-gray'}`}>{user.language || 'en'}</span></dd></div>
            <div className="flex justify-between"><dt className="font-bold">Tier</dt><dd><span className={`pill ${user.tier === 'premium' ? 'pill-purple' : 'pill-gray'}`}>{user.tier || 'free'}</span></dd></div>
            <div className="flex justify-between"><dt className="font-bold">Joined</dt><dd>{fmt(user.created_at)}</dd></div>
          </dl>
          <div className="mt-4">
            <div className="flex justify-between text-xs font-extrabold mb-1.5">
              <span style={{ color: 'var(--leaf-dark)' }}>Level {level}</span>
              <span style={{ color: 'var(--ink-faint)' }}>{xp.toLocaleString()} / {nextXp.toLocaleString()} XP</span>
            </div>
            <div className="h-2.5 rounded-full overflow-hidden" style={{ background: 'var(--leaf-soft)' }}>
              <div className="h-full rounded-full transition-all duration-700" style={{ width: `${pct}%`, background: 'linear-gradient(90deg,#166B36,#2E9E52)' }} />
            </div>
          </div>
        </div>
        <div className="card shadow-card p-5 rise rise-2">
          <h2 className="section-title mb-3">Stats</h2>
          <div className="grid grid-cols-3 gap-2.5 text-center">
            {[
              ['Scans', user.total_scans || 0, '#DDEBFD', '#1B5BAE'],
              ['Plants', user.plants_unlocked || 0, '#D8F0DC', '#12582B'],
              ['Rare', user.rare_count || 0, '#EAE2FE', '#5B32CC'],
              ['Normal', user.normal_count || 0, '#F1F8F1', '#4B5F51'],
              ['Special', user.special_rare_count || 0, '#FBEEDA', '#C77F0E'],
              ['Badges', user.achievements_earned || 0, '#FDE3E4', '#B3282D'],
            ].map(([l, v, bg, fg]: any) => (
              <div key={l} className="rounded-xl py-3" style={{ background: bg }}>
                <p className="text-xl font-black" style={{ color: fg }}>{v}</p>
                <p className="text-[10px] font-extrabold uppercase tracking-wide" style={{ color: fg, opacity: .75 }}>{l}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="card shadow-card p-5 mt-5 rise rise-3">
        <h2 className="section-title mb-3">Collection <span className="pill pill-green ml-1 align-middle">{plants.length}</span></h2>
        <div className="space-y-1">
          {plants.map((p: any) => (
            <div key={p.id} className="flex items-center justify-between text-sm py-2.5 px-2 rounded-lg row-hover border-b" style={{ borderColor: 'var(--line)' }}>
              <span className="font-extrabold" style={{ color: 'var(--ink)' }}>{(p.ai_data?.common_names?.[0]) || p.plant_id?.replaceAll('_', ' ')}</span>
              <RarityBadge rarity={p.rarity || 'normal'} />
              <span style={{ color: 'var(--ink-faint)' }}>👁 {p.sighting_count || 1}</span>
              <span className="text-xs font-semibold" style={{ color: 'var(--ink-faint)' }}>{fmt(p.unlocked_at)}</span>
            </div>
          ))}
          {plants.length === 0 && <p className="text-sm font-semibold text-center py-6" style={{ color: 'var(--ink-faint)' }}>No discoveries yet.</p>}
        </div>
      </div>
    </div>
  );
}
