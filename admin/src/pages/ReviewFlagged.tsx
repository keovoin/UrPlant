import { useState, useEffect } from 'react';
import { reviewApi } from '../services/api';
import toast from 'react-hot-toast';

export default function ReviewFlaggedPage() {
  const [items, setItems] = useState<any[]>([]);

  useEffect(() => { loadItems(); }, []);
  async function loadItems() {
    try {
      const res = await reviewApi.flagged({ page_size: 30 });
      setItems(res.photos || []);
    } catch { toast.error('Failed to load flagged photos'); }
  }

  async function handleAction(item: any, action: 'clear' | 'confirm_spoof') {
    try {
      await reviewApi.reviewFlagged(item.id, action);
      toast.success(action === 'clear' ? 'Flag cleared' : 'Confirmed as spoof');
      loadItems();
    } catch { toast.error('Action failed'); }
  }

  return (
    <div className="page-pad">
      <div className="mb-6 rise">
        <p className="text-xs font-extrabold uppercase tracking-widest" style={{ color: 'var(--ink-faint)' }}>UrPlant · moderation</p>
        <h1 className="text-3xl font-black tracking-tight mt-1" style={{ color: 'var(--ink)' }}>
          Flagged photos <span className="pill pill-red ml-2 align-middle">{items.length}</span>
        </h1>
      </div>
      <div className="space-y-3.5">
        {items.map((item: any, i: number) => (
          <div key={item.id} className="card shadow-card p-5 rise" style={{ animationDelay: `${Math.min(i, 6) * 40}ms` }}>
            <div className="flex justify-between items-start gap-4">
              <div className="min-w-0">
                <p className="font-black text-sm" style={{ color: 'var(--ink)' }}>Flag #{item.id?.substring(0, 8) || 'unknown'}</p>
                <p className="text-xs font-semibold mt-1" style={{ color: 'var(--ink-faint)' }}>User: {item.user_id?.substring(0, 8) || '-'}</p>
                {item.flags?.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 mt-2">
                    {item.flags.map((f: string, j: number) => (
                      <span key={j} className="pill pill-red">{f.replace(/_/g, ' ')}</span>
                    ))}
                  </div>
                )}
                {item.photo_url && (
                  <div className="mt-3 flex items-center gap-3">
                    <img src={item.photo_url} alt="flagged" className="w-16 h-16 rounded-xl object-cover border" style={{ borderColor: 'var(--line)' }} loading="lazy" />
                    <a href={item.photo_url} target="_blank" rel="noopener noreferrer" className="text-xs font-extrabold underline" style={{ color: 'var(--leaf)' }}>
                      View full photo →
                    </a>
                  </div>
                )}
              </div>
              <div className="flex gap-2 shrink-0">
                <button onClick={() => handleAction(item, 'clear')} className="btn-chunky h-9 text-[13px]">✓ Clear</button>
                <button onClick={() => handleAction(item, 'confirm_spoof')} className="btn-danger h-9 text-[13px]">✗ Spoof</button>
              </div>
            </div>
          </div>
        ))}
        {items.length === 0 && (
          <div className="card text-center py-14 rise">
            <div className="text-4xl mb-3">🛡️</div>
            <p className="font-black text-lg" style={{ color: 'var(--ink)' }}>All clear</p>
            <p className="text-sm font-semibold mt-1" style={{ color: 'var(--ink-faint)' }}>No flagged photos to review.</p>
          </div>
        )}
      </div>
    </div>
  );
}
