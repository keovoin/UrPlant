import { useState, useEffect } from 'react';
import { reviewApi, plantsApi } from '../services/api';
import toast from 'react-hot-toast';
import { RarityBadge } from './Dashboard';

export default function ReviewUnverifiedPage() {
  const [items, setItems] = useState<any[]>([]);

  useEffect(() => { loadItems(); }, []);
  async function loadItems() {
    try {
      const res = await reviewApi.unverified({ page_size: 30 });
      setItems(res.plants || []);
    } catch { toast.error('Failed to load'); }
  }

  async function handleApprove(item: any) {
    try {
      await reviewApi.reviewUnverified(item.id, 'approve', {
        name_en: item.plant_name || item.scientific_name || 'New Plant',
        scientific_name: item.scientific_name || '',
        rarity: 'normal',
        verified: true,
      });
      toast.success('Plant approved and added!');
      loadItems();
    } catch { toast.error('Failed to approve'); }
  }

  async function handleReject(item: any) {
    try {
      await reviewApi.reviewUnverified(item.id, 'reject');
      toast.success('Rejected');
      loadItems();
    } catch { toast.error('Failed to reject'); }
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Unverified Plants ({items.length})</h1>
      <div className="space-y-4">
        {items.map((item: any) => (
          <div key={item.id} className="bg-white rounded-xl shadow p-5">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-semibold">{item.plant_name || item.scientific_name || 'Unknown Plant'}</p>
                <p className="text-sm text-gray-500 italic">{item.scientific_name}</p>
                <p className="text-xs text-gray-400 mt-1">Found by: {item.user_ids?.length || 1} user(s)</p>
                {item.common_names?.length > 0 && (
                  <div className="flex gap-1 mt-1">
                    {item.common_names.map((n: string, i: number) => (
                      <span key={i} className="text-xs bg-gray-100 px-2 py-0.5 rounded">{n}</span>
                    ))}
                  </div>
                )}
              </div>
              <div className="flex gap-2">
                <button onClick={() => handleApprove(item)} className="px-3 py-1.5 bg-primary text-white rounded-lg text-sm hover:bg-primary-dark">✓ Approve</button>
                <button onClick={() => handleReject(item)} className="px-3 py-1.5 bg-red-500 text-white rounded-lg text-sm hover:bg-red-600">✗ Reject</button>
              </div>
            </div>
          </div>
        ))}
        {items.length === 0 && <p className="text-gray-500 text-center py-8">No unverified plants pending.</p>}
      </div>
    </div>
  );
}