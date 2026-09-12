/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#1B7A3D', light: '#2E9E52', dark: '#12582B', edge: '#0E4522', soft: '#D8F0DC' },
        rarity: { normal: '#1B7A3D', rare: '#2E7DE0', special: '#F4A82C' },
        ink: { DEFAULT: '#14281B', soft: '#4B5F51', faint: '#93A699' },
        canvas: '#F6FBF6',
        line: '#DDE9DE',
        gold: { DEFAULT: '#F4A82C', edge: '#C77F0E' },
        danger: '#E5484D',
        success: '#2FAE66',
      },
      boxShadow: {
        chunky: '0 4px 0 0 #0E4522',
        card: '0 8px 24px -12px rgba(20,40,27,0.25)',
      },
    },
  },
  plugins: [],
};
