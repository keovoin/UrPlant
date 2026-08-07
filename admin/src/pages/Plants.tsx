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
      const res = await plantsApi.list({ rarity: rarity === 'all' ? undefined : rarity, page_size: 50 });
      setPlants(res.plants || []);
    } catch { toast.error('Failed to load plants'); }
  }

  async function handleDelete(id: string) {
    if (!confirm('Delete this plant?')) return;
    try {
      await plantsApi.delete(id);
      toast.success('Plant deleted');
      loadPlants();
    } catch { toast.error('Failed to delete'); }
  }

  const filtered = plants.filter((p: any) => {
    if (!search) return true;
    const s = search.toLowerCase();
    return (p.name_en || '').toLowerCase().includes(s) || (p.scientific_name || '').toLowerCase().includes(s);
  });

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">Plants</h1>
        <Link to="/plants/new" className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark text-sm">+ Add Plant</Link>
      </div>
      <div className="flex gap-3 mb-4">
        <input placeholder="Search..." value={search} onChange={e => setSearch(e.target.value)} className="px-3 py-2 border rounded-lg w-64 text-sm" />
        <select value={rarity} onChange={e => setRarity(e.target.value)} className="px-3 py-2 border rounded-lg text-sm">
          <option value="all">All</option><option value="normal">Normal</option><option value="rare">Rare</option><option value="special_rare">Special Rare</option>
        </select>
      </div>
      <div className="grid grid-cols-3 gap-4">
        {filtered.map((p: any) => (
          <div key={p.id} className="bg-white rounded-xl shadow p-4">
            <div className="flex justify-between items-start mb-2">
              <div>
                <p className="font-semibold text-sm">{p.name_en || 'Unnamed'}</p>
                <p className="text-xs text-gray-400 italic">{p.scientific_name}</p>
              </div>
              <RarityBadge rarity={p.rarity} />
            </div>
            <p className="text-xs text-gray-500 mb-3">Family: {p.family || '-'} · Unlocks: {p.total_unlocks || 0}</p>
            <div className="flex gap-2">
              <Link to={`/plants/${p.id}/edit`} className="text-xs text-primary hover:underline">Edit</Link>
              <button onClick={() => handleDelete(p.id)} className="text-xs text-red-500 hover:underline">Delete</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}