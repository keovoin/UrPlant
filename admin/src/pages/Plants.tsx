import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { plantsApi } from '../services/api';
import { RarityBadge } from './Dashboard';
import toast from 'react-hot-toast';

export default function PlantsPage() {
  const [plants, setPlants] = useState<any[]>([]);
  const [search, setSearch] = useState('');
  const [rarity, setRarity] = useState('all');

  useEffect(() => { loadPlants(); }, [rarity]);

  async function loadPlants() {
    try {
      const res = await plantsApi.list({ rarity: rarity === 'all' ? undefined : rarity, page_size: 100 });
      setPlants(res.plants || []);
    } catch { toast.error('Failed to load plants'); }
  }

  async function handleDelete(id: string) {
    if (!confirm('Delete this species from the catalog?')) return;
    try {
      await plantsApi.delete(id);
      toast.success('Species deleted');
      loadPlants();
    } catch { toast.error('Failed to delete'); }
  }

  const filtered = plants.filter((p: any) => {
    if (!search) return true;
    const s = search.toLowerCase();
    return (p.name_en || '').toLowerCase().includes(s)
      || (p.name_kh || '').includes(s)
      || (p.scientific_name || '').toLowerCase().includes(s);
  });

  return (
    <div className="page-pad">
      <div className="flex items-end justify-between mb-6 flex-wrap gap-3 rise">
        <div>
          <p className="text-xs font-extrabold uppercase tracking-widest" style={{ color: 'var(--ink-faint)' }}>UrPlant · catalog</p>
          <h1 className="text-3xl font-black tracking-tight mt-1" style={{ color: 'var(--ink)' }}>
            Species <span className="pill pill-green ml-2 align-middle">{filtered.length}</span>
          </h1>
        </div>
        <div className="flex gap-2.5 items-center">
          <input placeholder="🔍 Search…" value={search} onChange={e => setSearch(e.target.value)} className="input h-10 !w-60" />
          <select value={rarity} onChange={e => setRarity(e.target.value)} className="input h-10 !py-0 !w-36">
            <option value="all">All rarities</option><option value="normal">★ Normal</option>
            <option value="rare">✦ Rare</option><option value="special_rare">✦✦ Special</option>
          </select>
          <Link to="/plants/new" className="btn-chunky h-10 whitespace-nowrap">＋ Add species</Link>
        </div>
      </div>

      <div className="grid grid-cols-2 xl:grid-cols-3 gap-4">
        {filtered.map((p: any, i: number) => (
          <div key={p.id} className="card shadow-card p-4 rise" style={{ animationDelay: `${Math.min(i % 12, 8) * 35}ms` }}>
            <div className="flex justify-between items-start gap-2 mb-1.5">
              <div className="min-w-0">
                <p className="font-black text-[15px] truncate" style={{ color: 'var(--ink)' }}>
                  {p.ai_generated && <span className="pill pill-purple mr-1.5 !text-[9px] align-middle">AI</span>}
                  {p.name_en || 'Unnamed'}
                </p>
                {p.name_kh && <p className="text-[13px] truncate" style={{ color: 'var(--ink-soft)' }}>{p.name_kh}</p>}
                <p className="text-xs italic truncate mt-0.5" style={{ color: 'var(--ink-faint)' }}>{p.scientific_name}</p>
              </div>
              <RarityBadge rarity={p.rarity} />
            </div>
            <div className="flex items-center gap-2 text-[11px] font-bold mb-3" style={{ color: 'var(--ink-faint)' }}>
              <button
                onClick={async () => {
                  try {
                    await plantsApi.update(p.id, { ...p, verified: !p.verified });
                    toast.success(p.verified ? 'Marked unverified' : 'Verified ✓');
                    loadPlants();
                  } catch { toast.error('Update failed'); }
                }}
                title="Toggle verified (shows in Encyclopedia)"
                className={`pill ${p.verified ? 'pill-green' : 'pill-gray'} !text-[10px] hover:brightness-95`}>
                {p.verified ? '✓ verified' : '☐ unverified'}
              </button>
              <span>Family: {p.family || '—'}</span>
              <span className="ml-auto" style={{ color: 'var(--gold-edge)' }}>👁 {p.total_unlocks || 0}</span>
            </div>
            <div className="flex gap-2">
              <Link to={`/plants/${p.id}/edit`} className="btn-quiet h-8 flex-1 !text-xs">✎ Edit</Link>
              <button onClick={() => handleDelete(p.id)} className="btn-danger h-8 !px-3 text-xs">🗑</button>
            </div>
          </div>
        ))}
        {filtered.length === 0 && (
          <div className="col-span-full card text-center py-14">
            <div className="text-4xl mb-3">🌱</div>
            <p className="font-black text-lg" style={{ color: 'var(--ink)' }}>Nothing here yet</p>
            <p className="text-sm font-semibold mt-1" style={{ color: 'var(--ink-faint)' }}>Add a species or adjust your search.</p>
          </div>
        )}
      </div>
    </div>
  );
}
