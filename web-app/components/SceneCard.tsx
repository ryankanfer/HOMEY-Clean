'use client';

interface SceneCardProps {
  icon: string;
  title: string;
  subtitle: string;
  onClick: () => void;
  delay?: number;
}

export default function SceneCard({ icon, title, subtitle, onClick, delay = 0 }: SceneCardProps) {
  return (
    <div
      onClick={onClick}
      className="glass rounded-3xl p-8 cursor-pointer transition-all duration-300 hover:-translate-y-2 hover:scale-[1.02] hover:shadow-2xl hover:shadow-primary/30 animate-scale-in"
      style={{ animationDelay: `${delay}s` }}
    >
      <div className="text-5xl mb-4 drop-shadow-lg">{icon}</div>
      <h3 className="text-2xl font-bold mb-2 tracking-wide">{title}</h3>
      <p className="text-sm text-white/80 leading-relaxed">{subtitle}</p>
    </div>
  );
}
