import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { plantsApi } from '../services/api';
import toast from 'react-hot-toast';

export default function PlantFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEdit = !!id;

  const [form, setForm] = useState<any>({
    name_en: '', name_kh: '', scientific_name: '',
    family: '', genus: '', species: '', rarity: 'normal',
    description_en: '', description_kh: '', origin_en: '', origin_kh: '',
    characteristics_en: '', characteristics_kh: '',
    habitat_en: '', habitat_kh: '', uses_en: '', uses_kh: '',
    fun_facts_en: [] as string[], fun_facts_kh: [] as string[],
    care_en: {}, care_kh: {},
    image_urls: [] as string[], thumbnail_url: '',
    verified: true,
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (id) {
      plantsApi.get(id).then(res => {
        if (res.plant) setForm((prev: any) => ({ ...prev, ...res.plant }));
      }).catch(() => toast.error('Failed to load plant'));
    }
  }, [id]);

  function update(field: string, value: any) {
    setForm((prev: any) => ({ ...prev, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form.scientific_name?.trim()) { toast.error('Scientific name is required'); return; }
    setLoading(true);
    try {
      // keep denormalized search mirror + bare aliases in sync, like createPlant does
      const payload = {
        ...form,
        scientific_name_lower: (form.scientific_name || '').toLowerCase(),
        description: form.description_en || form.description,
        origin: form.origin_en || form.origin,
        characteristics: form.characteristics_en || form.characteristics,
        habitat: form.habitat_en || form.habitat,
        uses: form.uses_en || form.uses,
        care: form.care_en || form.care,
        fun_facts: form.fun_facts_en || form.fun_facts,
      };
      if (isEdit) {
        await plantsApi.update(id!, payload);
        toast.success('Plant updated');
        navigate('/plants');
      } else {
        await plantsApi.create(payload);
        toast.success('Plant created');
        navigate('/plants');
      }
    } catch { toast.error('Failed to save'); }
    setLoading(false);
  }

  return (
    <div className="p-6 max-w-3xl mx-auto">
      <div className="mb-6 rise">
        <p className="text-xs font-extrabold uppercase tracking-widest" style={{ color: 'var(--ink-faint)' }}>UrPlant · catalog</p>
        <h1 className="text-3xl font-black tracking-tight mt-1" style={{ color: 'var(--ink)' }}>{isEdit ? 'Edit' : 'New'} species</h1>
      </div>

      <form onSubmit={handleSubmit} className="space-y-5">
        <section className="card shadow-card p-5 space-y-3.5 rise rise-1">
          <h2 className="section-title">🌱 Basic info</h2>
          <div className="grid grid-cols-2 gap-4">
            <Field label="English name" value={form.name_en} onChange={v => update('name_en', v)} />
            <Field label="Khmer name (ភាសាខ្មែរ)" value={form.name_kh} onChange={v => update('name_kh', v)} />
            <Field label="Scientific name" value={form.scientific_name} onChange={v => update('scientific_name', v)} required placeholder="Genus species" />
            <div>
              <label className="block text-[11px] font-extrabold uppercase tracking-wide mb-1" style={{ color: 'var(--ink-faint)' }}>Rarity</label>
              <select value={form.rarity} onChange={e => update('rarity', e.target.value)} className="input h-11 !py-0">
                <option value="normal">★ Normal</option><option value="rare">✦ Rare</option><option value="special_rare">✦✦ Special Rare</option>
              </select>
            </div>
          </div>
          <div className="flex items-center gap-2.5 pt-1">
            <input id="verified" type="checkbox" checked={!!form.verified} onChange={e => update('verified', e.target.checked)}
              className="w-4 h-4 accent-[var(--leaf)]" />
            <label htmlFor="verified" className="text-sm font-bold" style={{ color: 'var(--ink-soft)' }}>Verified — show in Encyclopedia</label>
          </div>
        </section>

        <section className="card shadow-card p-5 space-y-3.5 rise rise-2">
          <h2 className="section-title">🧬 Taxonomy</h2>
          <div className="grid grid-cols-3 gap-4">
            <Field label="Family" value={form.family} onChange={v => update('family', v)} />
            <Field label="Genus" value={form.genus} onChange={v => update('genus', v)} />
            <Field label="Species" value={form.species} onChange={v => update('species', v)} />
          </div>
        </section>

        <section className="card shadow-card p-5 space-y-3.5 rise rise-3">
          <h2 className="section-title">🇬🇧 Content (English)</h2>
          <Area label="Description" value={form.description_en} onChange={v => update('description_en', v)} />
          <div className="grid grid-cols-2 gap-4">
            <Field label="Origin" value={form.origin_en} onChange={v => update('origin_en', v)} />
            <Field label="Habitat" value={form.habitat_en} onChange={v => update('habitat_en', v)} />
          </div>
          <Area label="Characteristics" value={form.characteristics_en} onChange={v => update('characteristics_en', v)} rows={2} />
          <Area label="Uses" value={form.uses_en} onChange={v => update('uses_en', v)} rows={2} />
        </section>

        <section className="card shadow-card p-5 space-y-3.5 rise rise-4">
          <h2 className="section-title">🇰🇭 Content (Khmer)</h2>
          <Area label="Description" value={form.description_kh} onChange={v => update('description_kh', v)} />
          <div className="grid grid-cols-2 gap-4">
            <Field label="Origin" value={form.origin_kh} onChange={v => update('origin_kh', v)} />
            <Field label="Habitat" value={form.habitat_kh} onChange={v => update('habitat_kh', v)} />
          </div>
          <Area label="Characteristics" value={form.characteristics_kh} onChange={v => update('characteristics_kh', v)} rows={2} />
          <Area label="Uses" value={form.uses_kh} onChange={v => update('uses_kh', v)} rows={2} />
        </section>

        <div className="flex gap-3 pt-1 rise">
          <button type="submit" disabled={loading} className="btn-chunky h-11 px-6 disabled:opacity-50">
            {loading ? 'Saving…' : '💾 Save'}
          </button>
          <button type="button" onClick={() => navigate('/plants')} className="btn-quiet h-11 px-5">Cancel</button>
        </div>
      </form>
    </div>
  );
}

function Field({ label, value, onChange, required, placeholder }: { label: string; value: string; onChange: (v: string) => void; required?: boolean; placeholder?: string }) {
  return (
    <div>
      <label className="block text-[11px] font-extrabold uppercase tracking-wide mb-1" style={{ color: 'var(--ink-faint)' }}>{label}{required && <span style={{ color: 'var(--danger)' }}> *</span>}</label>
      <input value={value || ''} onChange={e => onChange(e.target.value)} required={required} placeholder={placeholder} className="input h-11 !py-0" />
    </div>
  );
}

function Area({ label, value, onChange, rows = 3 }: { label: string; value: string; onChange: (v: string) => void; rows?: number }) {
  return (
    <div>
      <label className="block text-[11px] font-extrabold uppercase tracking-wide mb-1" style={{ color: 'var(--ink-faint)' }}>{label}</label>
      <textarea value={value || ''} onChange={e => onChange(e.target.value)} rows={rows} className="input py-2.5 !h-auto resize-y" style={{ lineHeight: 1.5 }} />
    </div>
  );
}
