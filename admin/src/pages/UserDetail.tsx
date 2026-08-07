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

  if (!user) return <div className="p-6">Loading...</div>;

  const xp = user.total_xp || 0;
  const level = user.level || 1;
  const nextXp = level * level * 100;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">User: {user.display_name || user.email}</h1>
      <div className="grid grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow p-6">
          <h2 className="font-semibold mb-3">Profile</h2>
          <p className="text-sm">Email: {user.email}</p>
          <p className="text-sm">Language: {user.language || 'en'}</p>
          <p className="text-sm">Tier: {user.tier || 'free'}</p>
          <p className="text-sm">Level {level} · {xp}/{nextXp} XP</p>
        </div>
        <div className="bg-white rounded-xl shadow p-6">
          <h2 className="font-semibold mb-3">Stats</h2>
          <div className="grid grid-cols-2 gap-2 text-sm">
            <p>Scans: {user.total_scans || 0}</p>
            <p>Plants: {user.plants_unlocked || 0}</p>
            <p>Normal: {user.normal_count || 0}</p>
            <p>Rare: {user.rare_count || 0}</p>
            <p>Special: {user.special_rare_count || 0}</p>
            <p>Achievements: {user.achievements_earned || 0}</p>
          </div>
        </div>
      </div>
      <div className="bg-white rounded-xl shadow p-6 mt-6">
        <h2 className="font-semibold mb-3">Collection ({plants.length})</h2>
        <div className="space-y-2">
          {plants.map((p: any) => (
            <div key={p.id} className="flex items-center justify-between text-sm border-b pb-2">
              <span>{p.plant_id}</span>
              <RarityBadge rarity={p.rarity || 'normal'} />
              <span className="text-gray-500">Sightings: {p.sighting_count || 1}</span>
              <span className="text-xs text-gray-400">{new Date(p.unlocked_at?._seconds * 1000).toLocaleDateString()}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}