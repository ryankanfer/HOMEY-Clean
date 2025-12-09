import type { TutorialStep } from '@/components/Tutorial';

export const homeTutorialSteps: TutorialStep[] = [
  {
    id: 'welcome',
    title: 'Welcome to HOMEY! 🏠',
    description: 'Let us show you around your new home search companion. This quick tour will help you discover all the powerful features.',
    position: 'center',
  },
  {
    id: 'navigation',
    title: 'Easy Navigation',
    description: 'Use the bottom navigation bar to explore different sections: Search for properties, view Saved homes, check The Pulse, return Home, and manage Your profile.',
    targetSelector: 'nav',
    position: 'top',
  },
  {
    id: 'search',
    title: 'Discover Properties',
    description: 'Tap Search to browse available properties with advanced filters for neighborhoods, bedrooms, bathrooms, and price ranges.',
    targetSelector: '[href="/search"]',
    position: 'top',
  },
  {
    id: 'saved',
    title: 'Save Your Favorites',
    description: 'Found a place you love? Save it to your collection and access it anytime. You can even compare multiple properties side-by-side!',
    targetSelector: '[href="/saved"]',
    position: 'top',
  },
  {
    id: 'pulse',
    title: 'The Pulse - Social Features',
    description: 'Join the conversation! Share neighborhood vibes, vote on fun debates, and see what\'s happening in real-time across NYC.',
    targetSelector: '[href="/pulse"]',
    position: 'top',
  },
  {
    id: 'matchmaker',
    title: 'AI Matchmaker',
    description: 'Not sure what you want? Our AI Matchmaker asks you fun questions to understand your preferences and find your perfect home.',
    position: 'center',
  },
  {
    id: 'finish',
    title: 'You\'re All Set! 🎉',
    description: 'You now know the basics! Explore at your own pace. You can always access help from your profile settings.',
    position: 'center',
  },
];

export const searchTutorialSteps: TutorialStep[] = [
  {
    id: 'welcome',
    title: 'Search for Your Dream Home 🔍',
    description: 'Use the smart search bar to find properties. Try natural language like "3 bed under $2000" or search by neighborhood!',
    targetSelector: 'input[placeholder*="bed"]',
    position: 'bottom',
  },
  {
    id: 'filters',
    title: 'Advanced Filters ⚙️',
    description: 'Use these filter chips to narrow your search by type, price, and location. Tap "Filters" for even more options!',
    targetSelector: 'header',
    position: 'bottom',
  },
  {
    id: 'save-heart',
    title: 'Save Your Favorites 💝',
    description: 'Found something you love? Tap the heart icon on any property card to save it to your collection for later viewing!',
    position: 'center',
  },
];

export const pulseTutorialSteps: TutorialStep[] = [
  {
    id: 'welcome',
    title: 'Welcome to The Pulse! 📱',
    description: 'The Pulse is your connection to NYC\'s neighborhoods. See real-time updates, vote on community favorites, and share your experiences!',
    position: 'center',
  },
  {
    id: 'content',
    title: 'Real-Time Updates 🌟',
    description: 'Scroll through quick vibes, community votes, and neighborhood updates. Everything here helps you discover the authentic NYC experience!',
    targetSelector: 'main',
    position: 'top',
  },
  {
    id: 'share-vibe',
    title: 'Share Your Experience ✨',
    description: 'Ready to contribute? Look for the + button to share your neighborhood vibe, rate locations, and help others discover the city!',
    position: 'center',
  },
];

export const savedTutorialSteps: TutorialStep[] = [
  {
    id: 'collections',
    title: 'Your Saved Homes',
    description: 'All your favorite properties in one place, organized and ready for comparison.',
    position: 'center',
  },
  {
    id: 'filters-saved',
    title: 'Smart Filters',
    description: 'Use filters to see Price Drops, Open Houses, New Listings, or Best Matches based on your preferences.',
    targetSelector: 'header',
    position: 'bottom',
  },
  {
    id: 'compare',
    title: 'Compare Properties',
    description: 'Select up to 3 properties and tap Compare to see them side-by-side with detailed comparisons.',
    position: 'center',
  },
];

// Helper function to check if tutorial should show
export function shouldShowTutorial(tutorialKey: string): boolean {
  if (typeof window === 'undefined') return false;
  const completed = localStorage.getItem(`tutorial_${tutorialKey}`);
  return !completed;
}

// Helper function to reset a tutorial
export function resetTutorial(tutorialKey: string): void {
  if (typeof window === 'undefined') return;
  localStorage.removeItem(`tutorial_${tutorialKey}`);
}

// Helper function to reset all tutorials
export function resetAllTutorials(): void {
  if (typeof window === 'undefined') return;
  const keys = Object.keys(localStorage);
  keys.forEach(key => {
    if (key.startsWith('tutorial_')) {
      localStorage.removeItem(key);
    }
  });
}
