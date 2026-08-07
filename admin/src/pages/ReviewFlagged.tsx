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
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Flagged Photos ({items.length})</h1>
      <div className="space-y-4">
        {items.map((item: any) => (
          <div key={item.id} className="bg-white rounded-xl shadow p-5">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-semibold text-sm">Flag #{item.id?.substring(0, 8) || 'unknown'}</p>
                <p className="text-xs text-gray-500">User: {item.user_id?.substring(0, 8) || '-'}</p>
                {item.flags?.length > 0 && (
                  <div className="flex gap-1 mt-2">
                    {item.flags.map((f: string, i: number) => (
                      <span key={i} className="text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded">{f.replace(/_/g, ' ')}</span>
                    ))}
                  </div>
                )}
                {item.photo_url && (
                  <a href={item.photo_url} target="_blank" rel="noopener noreferrer" className="text-xs text-primary underline mt-2 inline-block">
                    View Photo →
                  </a>
                )}
              </div>
              <div className="flex gap-2">
                <button onClick={() => handleAction(item, 'clear')}
                  className="px-3 py-1.5 bg-green-500 text-white rounded-lg text-sm hover:bg-green-600">✓ Clear</button>
                <button onClick={() => handleAction(item, 'confirm_spoof')}
                  className="px-3 py-1.5 bg-red-500 text-white rounded-lg text-sm hover:bg-red-600">✗ Confirm Spoof</button>
              </div>
            </div>
          </div>
        ))}
        {items.length === 0 && <p className="text-gray-500 text-center py-8">No flagged photos to review.</p>}
      </div>
    </div>
  );
}