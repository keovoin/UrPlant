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
    verified: true,
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (id) {
      plantsApi.get(id).then(res => {
        if (res.plant) setForm(res.plant);
      });
    }
  }, [id]);

  function update(field: string, value: any) {
    setForm((prev: any) => ({ ...prev, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      if (isEdit) {
        await plantsApi.update(id!, form);
        toast.success('Plant updated');
      } else {
        await plantsApi.create(form);
        toast.success('Plant created');
        navigate('/plants');
      }
    } catch { toast.error('Failed to save'); }
    setLoading(false);
  }

  return (
    <div className="p-6 max-w-3xl">
      <h1 className="text-2xl font-bold mb-6">{isEdit ? 'Edit' : 'New'} Plant</h1>
      <form onSubmit={handleSubmit} className="space-y-6">
        <section className="bg-white rounded-xl shadow p-6 space-y-4">
          <h2 className="font-semibold">Basic Info</h2>
          <div className="grid grid-cols-2 gap-4">
            <Field label="English Name" value={form.name_en} onChange={v => update('name_en', v)} />
            <Field label="Khmer Name" value={form.name_kh} onChange={v => update('name_kh', v)} />
            <Field label="Scientific Name" value={form.scientific_name} onChange={v => update('scientific_name', v)} required />
            <div>
              <label className="block text-xs text-gray-500 mb-1">Rarity</label>
              <select value={form.rarity} onChange={e => update('rarity', e.target.value)} className="w-full px-3 py-2 border rounded-lg text-sm">
                <option value="normal">Normal</option><option value="rare">Rare</option><option value="special_rare">Special Rare</option>
              </select>
            </div>
          </div>
        </section>

        <section className="bg-white rounded-xl shadow p-6 space-y-4">
          <h2 className="font-semibold">Taxonomy</h2>
          <div className="grid grid-cols-3 gap-4">
            <Field label="Family" value={form.family} onChange={v => update('family', v)} />
            <Field label="Genus" value={form.genus} onChange={v => update('genus', v)} />
            <Field label="Species" value={form.species} onChange={v => update('species', v)} />
          </div>
        </section>

        <section className="bg-white rounded-xl shadow p-6 space-y-4">
          <h2 className="font-semibold">Content (English)</h2>
          <div className="space-y-4">
            <div><label className="block text-xs text-gray-500 mb-1">Description</label>
              <textarea value={form.description_en} onChange={e => update('description_en', e.target.value)} rows={3} className="w-full px-3 py-2 border rounded-lg text-sm" /></div>
            <Field label="Origin" value={form.origin_en} onChange={v => update('origin_en', v)} />
          </div>
        </section>

        <section className="bg-white rounded-xl shadow p-6 space-y-4">
          <h2 className="font-semibold">Content (Khmer)</h2>
          <div className="space-y-4">
            <div><label className="block text-xs text-gray-500 mb-1">Description</label>
              <textarea value={form.description_kh} onChange={e => update('description_kh', e.target.value)} rows={3} className="w-full px-3 py-2 border rounded-lg text-sm" /></div>
            <Field label="Origin" value={form.origin_kh} onChange={v => update('origin_kh', v)} />
          </div>
        </section>

        <div className="flex gap-3">
          <button type="submit" disabled={loading} className="px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark disabled:opacity-50">{loading ? 'Saving...' : 'Save'}</button>
          <button type="button" onClick={() => navigate('/plants')} className="px-6 py-2 border rounded-lg text-sm">Cancel</button>
        </div>
      </form>
    </div>
  );
}

function Field({ label, value, onChange, required }: { label: string; value: string; onChange: (v: string) => void; required?: boolean }) {
  return (
    <div>
      <label className="block text-xs text-gray-500 mb-1">{label}</label>
      <input value={value} onChange={e => onChange(e.target.value)} required={required} className="w-full px-3 py-2 border rounded-lg text-sm" />
    </div>
  );
}