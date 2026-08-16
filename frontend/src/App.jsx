import React, { useState, useEffect } from 'react';
import { Layers, PlusCircle, Package, RefreshCw, AlertCircle } from 'lucide-react';

const API_URL = 'http://34.238.239.42:8000/filamentos';

export default function App() {
  const [filamentos, setFilamentos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);

  const [formData, setFormData] = useState({
    cor: '',
    material: 'PLA',
    marca: '',
    peso_atual_gramas: ''
  });

  const fetchFilamentos = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(API_URL);
      if (!response.ok) {
        throw new Error(`Erro na requisição: ${response.statusText}`);
      }
      const data = await response.json();
      setFilamentos(data);
    } catch (err) {
      setError(err.message || 'Falha ao carregar estoque de filamentos.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFilamentos();
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);

    const payload = {
      cor: formData.cor,
      material: formData.material,
      marca: formData.marca,
      peso_atual_gramas: parseInt(formData.peso_atual_gramas, 10) || 0
    };

    try {
      const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      });

      if (!response.ok) {
        throw new Error('Falha ao cadastrar o filamento.');
      }

      setFormData({
        cor: '',
        material: 'PLA',
        marca: '',
        peso_atual_gramas: ''
      });
      
      fetchFilamentos();
    } catch (err) {
      setError(err.message || 'Ocorreu um erro ao salvar o filamento.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 p-4 sm:p-6 md:p-10">
      <div className="max-w-5xl mx-auto space-y-8">
        
        {/* Header */}
        <header className="flex flex-col sm:flex-row items-center justify-between border-b border-slate-800 pb-5 gap-4">
          <div className="flex items-center space-x-3">
            <div className="bg-sky-500 p-2.5 rounded-xl text-slate-950 font-bold shadow-lg shadow-sky-500/20">
              <Layers className="w-8 h-8" />
            </div>
            <div>
              <h1 className="text-3xl font-extrabold tracking-tight text-white">
                FilaFlow <span className="text-sky-400 font-medium text-lg">- Estoque 3D</span>
              </h1>
              <p className="text-slate-400 text-sm">Gerenciamento inteligente e controle de filamentos para impressão 3D</p>
            </div>
          </div>
          <button
            onClick={fetchFilamentos}
            disabled={loading}
            className="flex items-center space-x-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 active:bg-slate-800 text-slate-200 text-sm font-medium rounded-lg transition border border-slate-700 disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            <span>Atualizar Lista</span>
          </button>
        </header>

        {/* Notificação de Erro */}
        {error && (
          <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-4 flex items-center space-x-3 text-red-400">
            <AlertCircle className="w-5 h-5 flex-shrink-0" />
            <span className="text-sm font-medium">{error}</span>
          </div>
        )}

        {/* Formulário de Cadastro */}
        <section className="bg-slate-800/60 border border-slate-800 rounded-2xl p-6 shadow-xl backdrop-blur-sm">
          <h2 className="text-xl font-semibold mb-4 flex items-center space-x-2 text-white">
            <PlusCircle className="w-5 h-5 text-sky-400" />
            <span>Adicionar Novo Filamento</span>
          </h2>
          <form onSubmit={handleSubmit} className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1 uppercase tracking-wider">Cor</label>
              <input
                type="text"
                name="cor"
                required
                placeholder="Ex: Azul Cobalto"
                value={formData.cor}
                onChange={handleChange}
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3.5 py-2.5 text-sm text-slate-100 placeholder-slate-500 focus:outline-none focus:border-sky-500 transition"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1 uppercase tracking-wider">Material</label>
              <select
                name="material"
                value={formData.material}
                onChange={handleChange}
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3.5 py-2.5 text-sm text-slate-100 focus:outline-none focus:border-sky-500 transition"
              >
                <option value="PLA">PLA</option>
                <option value="PETG">PETG</option>
                <option value="ABS">ABS</option>
                <option value="TPU">TPU</option>
                <option value="ASA">ASA</option>
                <option value="Nylon">Nylon</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1 uppercase tracking-wider">Marca</label>
              <input
                type="text"
                name="marca"
                required
                placeholder="Ex: Tecnocubo 3D / 3D Lab"
                value={formData.marca}
                onChange={handleChange}
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3.5 py-2.5 text-sm text-slate-100 placeholder-slate-500 focus:outline-none focus:border-sky-500 transition"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1 uppercase tracking-wider">Peso (Gramas)</label>
              <input
                type="number"
                name="peso_atual_gramas"
                min="0"
                required
                placeholder="Ex: 1000"
                value={formData.peso_atual_gramas}
                onChange={handleChange}
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3.5 py-2.5 text-sm text-slate-100 placeholder-slate-500 focus:outline-none focus:border-sky-500 transition"
              />
            </div>

            <div className="flex items-end">
              <button
                type="submit"
                disabled={submitting}
                className="w-full bg-sky-500 hover:bg-sky-400 active:bg-sky-600 text-slate-950 font-semibold px-4 py-2.5 rounded-lg transition shadow-md shadow-sky-500/10 flex items-center justify-center space-x-2 disabled:opacity-50"
              >
                {submitting ? (
                  <RefreshCw className="w-5 h-5 animate-spin" />
                ) : (
                  <>
                    <PlusCircle className="w-5 h-5" />
                    <span>Salvar Filamento</span>
                  </>
                )}
              </button>
            </div>
          </form>
        </section>

        {/* Tabela / Lista de Filamentos */}
        <section className="bg-slate-800/60 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
          <div className="p-6 border-b border-slate-800 flex items-center justify-between">
            <h2 className="text-xl font-semibold flex items-center space-x-2 text-white">
              <Package className="w-5 h-5 text-sky-400" />
              <span>Inventário de Filamentos</span>
            </h2>
            <span className="bg-slate-700 text-slate-300 text-xs px-2.5 py-1 rounded-full font-medium">
              Total: {filamentos.length}
            </span>
          </div>

          {loading && filamentos.length === 0 ? (
            <div className="p-12 text-center text-slate-400 flex flex-col items-center space-y-3">
              <RefreshCw className="w-8 h-8 animate-spin text-sky-400" />
              <p>Carregando estoque de filamentos...</p>
            </div>
          ) : filamentos.length === 0 ? (
            <div className="p-12 text-center text-slate-400 space-y-2">
              <p className="text-base">Nenhum filamento cadastrado até o momento.</p>
              <p className="text-xs text-slate-500">Utilize o formulário acima para adicionar os seus carretéis.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-slate-900/50 text-slate-400 text-xs uppercase tracking-wider border-b border-slate-800">
                    <th className="py-3.5 px-6 font-semibold">ID</th>
                    <th className="py-3.5 px-6 font-semibold">Cor</th>
                    <th className="py-3.5 px-6 font-semibold">Material</th>
                    <th className="py-3.5 px-6 font-semibold">Marca</th>
                    <th className="py-3.5 px-6 font-semibold text-right">Peso Atual</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800/60 text-sm">
                  {filamentos.map((item) => (
                    <tr key={item.id} className="hover:bg-slate-800/40 transition">
                      <td className="py-4 px-6 font-mono text-xs text-slate-500 truncate max-w-[120px]" title={item.id}>
                        {item.id}
                      </td>
                      <td className="py-4 px-6 font-medium text-slate-100 flex items-center space-x-2">
                        <span className="w-3 h-3 rounded-full bg-sky-400 inline-block"></span>
                        <span>{item.cor}</span>
                      </td>
                      <td className="py-4 px-6">
                        <span className="bg-slate-700/60 text-sky-300 text-xs px-2 py-1 rounded font-mono">
                          {item.material}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-slate-300">{item.marca}</td>
                      <td className="py-4 px-6 text-right font-medium text-slate-200">
                        {item.peso_atual_gramas} g
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>

      </div>
    </div>
  );
}
