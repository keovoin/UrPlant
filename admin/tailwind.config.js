/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#1B5E20', light: '#4CAF50', dark: '#0D3B0F' },
        rarity: { normal: '#4CAF50', rare: '#2196F3', special: '#FFD700' },
        background: '#FAF3E3',
      },
    },
  },
  plugins: [],
};