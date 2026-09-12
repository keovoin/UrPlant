import { useState, useEffect } from 'react';
import { reviewApi } from '../services/api';
import toast from 'react-hot-toast';

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
    <div className="page-pad">
      <div className="mb-6 rise">
        <p className="text-xs font-extrabold uppercase tracking-widest" style={{ color: 'var(--ink-faint)' }}>UrPlant · moderation</p>
        <h1 className="text-3xl font-black tracking-tight mt-1" style={{ color: 'var(--ink)' }}>
          Unverified species <span className="pill pill-gold ml-2 align-middle">{items.length}</span>
        </h1>
      </div>
      <div className="space-y-3.5">
        {items.map((item: any, i: number) => (
          <div key={item.id} className="card shadow-card p-5 rise" style={{ animationDelay: `${Math.min(i, 6) * 40}ms` }}>
            <div className="flex justify-between items-start gap-4">
              <div className="min-w-0">
                <p className="font-black text-base" style={{ color: 'var(--ink)' }}>{item.plant_name || item.scientific_name || 'Unknown Plant'}</p>
                <p className="text-sm italic mt-0.5" style={{ color: 'var(--ink-faint)' }}>{item.scientific_name}</p>
                <p className="text-xs font-bold mt-1.5" style={{ color: 'var(--ink-faint)' }}>
                  🔍 Found by {item.user_ids?.length || 1} explorer(s)
                  {item.confidence ? ` · last confidence ${(item.confidence * 100).toFixed(0)}%` : ''}
                </p>
                {item.common_names?.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 mt-2">
                    {item.common_names.map((n: string, j: number) => (
                      <span key={j} className="pill pill-gray">{n}</span>
                    ))}
                  </div>
                )}
              </div>
              <div className="flex gap-2 shrink-0">
                <button onClick={() => handleApprove(item)} className="btn-chunky h-9 text-[13px]">✓ Approve</button>
                <button onClick={() => handleReject(item)} className="btn-danger h-9 text-[13px]">✗ Reject</button>
              </div>
            </div>
          </div>
        ))}
        {items.length === 0 && (
          <div className="card text-center py-14 rise">
            <div className="text-4xl mb-3">✅</div>
            <p className="font-black text-lg" style={{ color: 'var(--ink)' }}>Queue is clear</p>
            <p className="text-sm font-semibold mt-1" style={{ color: 'var(--ink-faint)' }}>No unverified plants pending.</p>
          </div>
        )}
      </div>
    </div>
  );
}
