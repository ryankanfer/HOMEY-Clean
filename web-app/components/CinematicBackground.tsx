'use client';

type TimeOfDay = 'sunrise' | 'day' | 'sunset' | 'night';

interface CinematicBackgroundProps {
  timeOfDay: TimeOfDay;
}

const gradients = {
  sunrise: 'from-[#8fd7ff] via-[#a9c3ff] to-[#bff6ea]',
  day: 'from-[#5ab5e8] via-[#7bbfe8] to-[#9dd4e8]',
  sunset: 'from-[#fa8c72] via-[#b28cd9] to-[#334d80]',
  night: 'from-[#0d1226] via-[#0f132e] to-[#08080f]',
};

export default function CinematicBackground({ timeOfDay }: CinematicBackgroundProps) {
  return (
    <div className="fixed inset-0 z-0 transition-all duration-1000">
      <div className={`absolute inset-0 bg-gradient-to-b ${gradients[timeOfDay]}`} />

      {/* Vignette */}
      <div className="absolute inset-0 bg-radial-gradient from-transparent via-transparent to-black/30" />

      {/* Grain texture */}
      <div className="absolute inset-0 opacity-[0.05] mix-blend-overlay bg-noise" />
    </div>
  );
}
