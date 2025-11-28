'use client';

export default function AuroraBackground() {
  return (
    <div className="fixed inset-0 z-0 overflow-hidden">
      {/* Base gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-indigo-950 via-slate-900 to-slate-800" />

      {/* Rotating rays */}
      <div className="absolute inset-0 animate-spin-slow opacity-60">
        <div
          className="absolute inset-[-50%] bg-conic-gradient blur-3xl"
          style={{
            background: 'conic-gradient(from 0deg, transparent, rgba(147, 51, 234, 0.3), transparent, rgba(59, 130, 246, 0.3), transparent, rgba(168, 85, 247, 0.3), transparent)',
          }}
        />
      </div>

      {/* Floating particles */}
      <div className="absolute top-[10%] left-[20%] w-[300px] h-[300px] bg-purple-600/40 rounded-full blur-[80px] opacity-30 animate-float-1" />
      <div className="absolute top-[60%] left-[70%] w-[250px] h-[250px] bg-blue-600/40 rounded-full blur-[80px] opacity-30 animate-float-2" />
      <div className="absolute top-[30%] left-[60%] w-[280px] h-[280px] bg-violet-600/40 rounded-full blur-[80px] opacity-30 animate-float-3" />
    </div>
  );
}
