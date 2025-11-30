'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import CinematicBackground from '@/components/CinematicBackground';
import SceneCard from '@/components/SceneCard';

type TimeOfDay = 'sunrise' | 'day' | 'sunset' | 'night';

const heroMessages = {
  sunrise: ['Golden Hour', 'Early Riser Energy', 'Coffee Then Closings', 'Doors Open Early'],
  day: ['Welcome Home', "Let's Make Moves", 'Inbox: New Listings', 'Tour Ready, Are You?'],
  sunset: ['Golden Hour Redux', 'Last Light, Best Picks', 'Deals Love Dusk', 'One More Refresh'],
  night: ['Stargazing', 'Midnight Zillow Scroller', 'Dream Home, Literally', 'Sleep Is Optional'],
};

const scenes = [
  {
    id: 'scout',
    icon: '🔍',
    title: 'Scout',
    subtitle: 'AR property search with map visualization and swipeable cards',
  },
  {
    id: 'drew',
    icon: '👥',
    title: 'Drew',
    subtitle: 'Connect with real estate professionals and get AI-powered recommendations',
  },
  {
    id: 'isla',
    icon: '📊',
    title: 'Isla',
    subtitle: 'Real-time market insights, analytics, and affordability tracking',
  },
  {
    id: 'viza',
    icon: '🎨',
    title: 'Viza',
    subtitle: '2D/3D visualization with drag-and-drop interior design',
  },
  {
    id: 'paige',
    icon: '📄',
    title: 'Paige',
    subtitle: 'Document management with scanning and verification',
  },
  {
    id: 'charlie',
    icon: '💬',
    title: 'Charlie',
    subtitle: 'Your AI companion for guidance through your home buying journey',
  },
];

export default function DashboardPage() {
  const router = useRouter();
  const [timeOfDay, setTimeOfDay] = useState<TimeOfDay>('day');
  const [heroText, setHeroText] = useState('Welcome Home');

  const handleTimeChange = (time: TimeOfDay) => {
    setTimeOfDay(time);
    const messages = heroMessages[time];
    setHeroText(messages[Math.floor(Math.random() * messages.length)]);
  };

  const handleSceneClick = (sceneId: string) => {
    if (sceneId === 'scout') {
      router.push('/scout');
    } else {
      alert(`Opening ${sceneId} scene...\n\nIn the full app, this would navigate to the ${sceneId} feature.`);
    }
  };

  return (
    <main className="relative min-h-screen">
      <CinematicBackground timeOfDay={timeOfDay} />

      {/* Header */}
      <header className="relative z-20 py-5 text-center bg-gradient-to-b from-black/15 to-transparent">
        <h1 className="text-2xl font-light tracking-[2px] text-white drop-shadow-lg">
          HOMEY
        </h1>
      </header>

      {/* Settings Button */}
      <button
        className="fixed top-5 right-5 z-50 w-12 h-12 glass rounded-full flex items-center justify-center text-xl hover:bg-white/15 transition-all hover:rotate-90"
        onClick={() => alert('Settings panel would open here')}
      >
        ⚙️
      </button>

      {/* Time Toggle */}
      <div className="fixed top-20 right-5 z-50 glass rounded-xl p-2 flex flex-col gap-2">
        {[
          { time: 'sunrise', icon: '🌅' },
          { time: 'day', icon: '☀️' },
          { time: 'sunset', icon: '🌇' },
          { time: 'night', icon: '🌙' },
        ].map(({ time, icon }) => (
          <button
            key={time}
            onClick={() => handleTimeChange(time as TimeOfDay)}
            className={`w-11 h-11 rounded-lg flex items-center justify-center text-xl transition-all hover:bg-white/20 hover:scale-110 ${
              timeOfDay === time ? 'bg-primary/50 border border-primary/80' : 'bg-white/10 border border-white/20'
            }`}
            title={time}
          >
            {icon}
          </button>
        ))}
      </div>

      {/* Main Content */}
      <div className="relative z-10 min-h-[calc(100vh-100px)] flex flex-col items-center justify-center px-5 py-10">
        {/* Hero Text */}
        <h2 className="text-3xl font-bold text-center mb-16 drop-shadow-xl animate-fade-in">
          {heroText}
        </h2>

        {/* Scenes Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl w-full mb-20">
          {scenes.map((scene, index) => (
            <SceneCard
              key={scene.id}
              {...scene}
              onClick={() => handleSceneClick(scene.id)}
              delay={index * 0.1}
            />
          ))}
        </div>
      </div>

      {/* Floating CTA */}
      <button
        className="fixed bottom-8 left-1/2 -translate-x-1/2 z-50 px-8 py-3.5 glass-strong rounded-full text-white text-lg font-bold tracking-wide shadow-2xl transition-all hover:scale-105 animate-pulse-subtle flex items-center gap-3"
        onClick={() => handleSceneClick('search')}
      >
        <span>🔍</span>
        <span>Find home</span>
      </button>
    </main>
  );
}
