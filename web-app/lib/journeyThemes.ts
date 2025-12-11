export interface JourneyTheme {
  id: string;
  name: string;
  type: 'gradient' | 'monochrome';
  colors: {
    completed: string; // Hex color
    current: string; // Hex color or gradient
    currentGradient?: string; // CSS gradient string
    upcoming: string; // Hex color
    line: {
      completed: string; // Hex color
      upcoming: string; // Hex color
    };
    text: {
      stageName: string; // Hex color
      progress: string; // Hex color
    };
  };
  preview: string; // CSS gradient or solid color for preview
  pulse?: boolean;
}

export const JOURNEY_THEMES: JourneyTheme[] = [
  {
    id: 'default',
    name: 'Purple Dreams',
    type: 'gradient',
    colors: {
      completed: '#10b981',
      current: '#a855f7',
      currentGradient: 'linear-gradient(to right, #a855f7, #ec4899)',
      upcoming: 'rgba(255, 255, 255, 0.1)',
      line: {
        completed: '#10b981',
        upcoming: 'rgba(255, 255, 255, 0.1)',
      },
      text: {
        stageName: '#d8b4fe',
        progress: 'rgba(255, 255, 255, 0.6)',
      },
    },
    preview: 'linear-gradient(to right, #a855f7, #ec4899)',
    pulse: true,
  },
  {
    id: 'ocean',
    name: 'Ocean Breeze',
    type: 'gradient',
    colors: {
      completed: '#22d3ee',
      current: '#3b82f6',
      currentGradient: 'linear-gradient(to right, #3b82f6, #22d3ee)',
      upcoming: 'rgba(255, 255, 255, 0.1)',
      line: {
        completed: '#22d3ee',
        upcoming: 'rgba(255, 255, 255, 0.1)',
      },
      text: {
        stageName: '#67e8f9',
        progress: 'rgba(255, 255, 255, 0.6)',
      },
    },
    preview: 'linear-gradient(to right, #3b82f6, #22d3ee)',
    pulse: true,
  },
  {
    id: 'sunrise',
    name: 'Sunrise',
    type: 'gradient',
    colors: {
      completed: '#fbbf24',
      current: '#f59e0b',
      currentGradient: 'linear-gradient(to right, #f59e0b, #fbbf24)',
      upcoming: 'rgba(255, 255, 255, 0.1)',
      line: {
        completed: '#fbbf24',
        upcoming: 'rgba(255, 255, 255, 0.1)',
      },
      text: {
        stageName: '#fcd34d',
        progress: 'rgba(255, 255, 255, 0.6)',
      },
    },
    preview: 'linear-gradient(to right, #f59e0b, #fbbf24)',
    pulse: true,
  },
  {
    id: 'sunset',
    name: 'Sunset Glow',
    type: 'gradient',
    colors: {
      completed: '#facc15',
      current: '#f97316',
      currentGradient: 'linear-gradient(to right, #f97316, #ec4899)',
      upcoming: 'rgba(255, 255, 255, 0.1)',
      line: {
        completed: '#facc15',
        upcoming: 'rgba(255, 255, 255, 0.1)',
      },
      text: {
        stageName: '#fdba74',
        progress: 'rgba(255, 255, 255, 0.6)',
      },
    },
    preview: 'linear-gradient(to right, #f97316, #ec4899)',
    pulse: true,
  },
  {
    id: 'forest',
    name: 'Forest Path',
    type: 'gradient',
    colors: {
      completed: '#34d399',
      current: '#22c55e',
      currentGradient: 'linear-gradient(to right, #22c55e, #34d399)',
      upcoming: 'rgba(255, 255, 255, 0.1)',
      line: {
        completed: '#34d399',
        upcoming: 'rgba(255, 255, 255, 0.1)',
      },
      text: {
        stageName: '#6ee7b7',
        progress: 'rgba(255, 255, 255, 0.6)',
      },
    },
    preview: 'linear-gradient(to right, #22c55e, #34d399)',
    pulse: true,
  },
  {
    id: 'royal',
    name: 'Royal Indigo',
    type: 'gradient',
    colors: {
      completed: '#818cf8',
      current: '#4f46e5',
      currentGradient: 'linear-gradient(to right, #4f46e5, #a855f7)',
      upcoming: 'rgba(255, 255, 255, 0.1)',
      line: {
        completed: '#818cf8',
        upcoming: 'rgba(255, 255, 255, 0.1)',
      },
      text: {
        stageName: '#a5b4fc',
        progress: 'rgba(255, 255, 255, 0.6)',
      },
    },
    preview: 'linear-gradient(to right, #4f46e5, #a855f7)',
    pulse: true,
  },
  {
    id: 'mono-light',
    name: 'Light Mode',
    type: 'monochrome',
    colors: {
      completed: '#ffffff',
      current: '#ffffff',
      upcoming: 'rgba(255, 255, 255, 0.2)',
      line: {
        completed: '#ffffff',
        upcoming: 'rgba(255, 255, 255, 0.2)',
      },
      text: {
        stageName: '#ffffff',
        progress: 'rgba(255, 255, 255, 0.8)',
      },
    },
    preview: '#ffffff',
    pulse: true,
  },
  {
    id: 'mono-dark',
    name: 'Dark Mode',
    type: 'monochrome',
    colors: {
      completed: '#475569',
      current: '#94a3b8',
      upcoming: 'rgba(71, 85, 105, 0.3)',
      line: {
        completed: '#475569',
        upcoming: '#1e293b',
      },
      text: {
        stageName: '#cbd5e1',
        progress: '#94a3b8',
      },
    },
    preview: '#475569',
    pulse: true,
  },
  {
    id: 'mono-minimal',
    name: 'Minimal',
    type: 'monochrome',
    colors: {
      completed: '#d1d5db',
      current: '#f3f4f6',
      upcoming: 'rgba(107, 114, 128, 0.3)',
      line: {
        completed: '#d1d5db',
        upcoming: '#374151',
      },
      text: {
        stageName: '#e5e7eb',
        progress: '#9ca3af',
      },
    },
    preview: '#d1d5db',
    pulse: true,
  },
];

export function getThemeById(id: string): JourneyTheme {
  return JOURNEY_THEMES.find(theme => theme.id === id) || JOURNEY_THEMES[0];
}

export function saveThemePreference(themeId: string) {
  if (typeof window !== 'undefined') {
    localStorage.setItem('journey-theme', themeId);
  }
}

export function getThemePreference(): string {
  if (typeof window !== 'undefined') {
    return localStorage.getItem('journey-theme') || 'default';
  }
  return 'default';
}
