'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { analytics } from '@/lib/analytics';

interface QuickAction {
  id: string;
  label: string;
  icon: string;
  action: () => void;
  keywords: string[];
}

interface Page {
  id: string;
  name: string;
  path: string;
  icon: string;
  keywords: string[];
  description: string;
}

interface SearchResult {
  id: string;
  type: 'page' | 'action' | 'property' | 'document' | 'contact';
  label: string;
  sublabel?: string;
  icon: string;
  action: () => void;
}

const PAGES: Page[] = [
  { id: 'home', name: 'Home', path: '/home', icon: '🏠', keywords: ['home', 'feed', 'main'], description: 'Your personalized feed' },
  { id: 'search', name: 'Search', path: '/search', icon: '🔍', keywords: ['search', 'find', 'properties', 'apartments'], description: 'Find properties' },
  { id: 'matchmaker', name: 'Matchmaker', path: '/matchmaker', icon: '💘', keywords: ['matchmaker', 'swipe', 'match', 'like'], description: 'Swipe to train AI' },
  { id: 'studio', name: 'Style Studio', path: '/studio', icon: '🎨', keywords: ['studio', 'style', 'design', 'aesthetic'], description: 'Learn your design style' },
  { id: 'scout', name: 'Scout', path: '/scout', icon: '🎯', keywords: ['scout', 'properties', 'recommendations'], description: 'AI property recommendations' },
  { id: 'calendar', name: 'Calendar', path: '/calendar', icon: '📅', keywords: ['calendar', 'schedule', 'tours', 'events', 'deadlines', 'reminders'], description: 'Your schedule & tours' },
  { id: 'saved', name: 'Saved', path: '/saved', icon: '❤️', keywords: ['saved', 'favorites', 'liked', 'bookmarks'], description: 'Your saved properties' },
  { id: 'vault', name: 'Vault', path: '/vault', icon: '🔐', keywords: ['vault', 'documents', 'lease', 'contracts', '1040', 'files'], description: 'Secure documents' },
  { id: 'directory', name: 'Directory', path: '/directory', icon: '👥', keywords: ['directory', 'contacts', 'agents', 'movers', 'people'], description: 'Professional network' },
  { id: 'learn', name: 'Learn', path: '/learn', icon: '📚', keywords: ['learn', 'education', 'tips', 'guides'], description: 'Rental guides & tips' },
  { id: 'teach', name: 'Teach HOMEY', path: '/teach', icon: '🎓', keywords: ['teach', 'preferences', 'onboarding', 'setup'], description: 'Set preferences' },
  { id: 'settings', name: 'Settings', path: '/settings', icon: '⚙️', keywords: ['settings', 'profile', 'account'], description: 'Account settings' },
];

interface CommandPaletteProps {
  isOpen?: boolean;
  onClose?: () => void;
}

export default function CommandPalette({ isOpen: externalIsOpen, onClose }: CommandPaletteProps = {}) {
  const router = useRouter();
  const pathname = usePathname();
  const [internalIsOpen, setInternalIsOpen] = useState(false);

  // Use external control if provided, otherwise use internal state
  const isOpen = externalIsOpen !== undefined ? externalIsOpen : internalIsOpen;
  const setIsOpen = onClose ? (value: boolean) => { if (!value) onClose(); } : setInternalIsOpen;
  const [query, setQuery] = useState('');
  const [recentPages, setRecentPages] = useState<string[]>([]);
  const [frequentPages, setFrequentPages] = useState<{ page: string; count: number }[]>([]);
  const inputRef = useRef<HTMLInputElement>(null);

  // Helper to close the palette (works with both internal and external control)
  const closeCommandPalette = () => {
    if (onClose) {
      onClose();
    } else {
      setInternalIsOpen(false);
    }
  };

  useEffect(() => {
    // Load recent and frequent pages from localStorage
    const recent = JSON.parse(localStorage.getItem('homey_recent_pages') || '[]');
    const frequent = JSON.parse(localStorage.getItem('homey_page_frequency') || '{}');

    setRecentPages(recent);

    // Convert frequency object to sorted array
    const frequencyArray = Object.entries(frequent)
      .map(([page, count]) => ({ page, count: count as number }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    setFrequentPages(frequencyArray);

    // Keyboard shortcut: Cmd+K or Ctrl+K (only if not externally controlled)
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        if (externalIsOpen === undefined) {
          setInternalIsOpen(true);
        }
      }
      if (e.key === 'Escape') {
        if (externalIsOpen === undefined) {
          setInternalIsOpen(false);
        } else if (onClose) {
          onClose();
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  useEffect(() => {
    if (isOpen && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isOpen]);

  const trackPageVisit = (pageId: string) => {
    // Track in recent pages
    const recent = JSON.parse(localStorage.getItem('homey_recent_pages') || '[]');
    const updated = [pageId, ...recent.filter((p: string) => p !== pageId)].slice(0, 10);
    localStorage.setItem('homey_recent_pages', JSON.stringify(updated));

    // Track frequency
    const frequency = JSON.parse(localStorage.getItem('homey_page_frequency') || '{}');
    frequency[pageId] = (frequency[pageId] || 0) + 1;
    localStorage.setItem('homey_page_frequency', JSON.stringify(frequency));

    // Analytics
    analytics.click('command_palette_navigate', pageId, { query });
  };

  const navigateToPage = (path: string, pageId: string) => {
    trackPageVisit(pageId);
    closeCommandPalette();
    setQuery('');
    router.push(path);
  };

  const getContextualActions = (): QuickAction[] => {
    const actions: QuickAction[] = [];

    // Property detail page (Scout)
    if (pathname?.startsWith('/scout/')) {
      actions.push({
        id: 'save_property',
        label: 'Save This Property',
        icon: '❤️',
        action: () => {
          // Would trigger save action
          analytics.click('contextual_action', 'save_property');
        },
        keywords: ['save', 'like', 'favorite'],
      });
      actions.push({
        id: 'share_property',
        label: 'Share Property',
        icon: '↗️',
        action: () => {
          if (navigator.share) {
            navigator.share({ title: 'Check out this property', url: window.location.href });
          }
          analytics.click('contextual_action', 'share_property');
        },
        keywords: ['share', 'send'],
      });
      actions.push({
        id: 'contact_agent',
        label: 'Contact Agent',
        icon: '📧',
        action: () => navigateToPage('/directory?filter=agents', 'directory'),
        keywords: ['contact', 'agent', 'realtor'],
      });
      actions.push({
        id: 'view_similar',
        label: 'View Similar Properties',
        icon: '🔍',
        action: () => navigateToPage('/search', 'search'),
        keywords: ['similar', 'like this'],
      });
    }

    // Vault page
    if (pathname === '/vault') {
      actions.push({
        id: 'upload_doc',
        label: 'Upload Document',
        icon: '📤',
        action: () => {
          analytics.click('contextual_action', 'upload_document');
        },
        keywords: ['upload', 'add', 'new'],
      });
      actions.push({
        id: 'search_docs',
        label: 'Search Documents',
        icon: '🔍',
        action: () => {
          analytics.click('contextual_action', 'search_documents');
        },
        keywords: ['search', 'find'],
      });
    }

    // Directory page
    if (pathname === '/directory') {
      actions.push({
        id: 'find_agent',
        label: 'Find Agent',
        icon: '🏢',
        action: () => {
          analytics.click('contextual_action', 'find_agent');
        },
        keywords: ['agent', 'realtor'],
      });
      actions.push({
        id: 'find_mover',
        label: 'Find Mover',
        icon: '🚚',
        action: () => {
          analytics.click('contextual_action', 'find_mover');
        },
        keywords: ['mover', 'moving'],
      });
      actions.push({
        id: 'add_contact',
        label: 'Add Contact',
        icon: '➕',
        action: () => {
          analytics.click('contextual_action', 'add_contact');
        },
        keywords: ['add', 'new', 'contact'],
      });
    }

    // Matchmaker page
    if (pathname === '/matchmaker') {
      actions.push({
        id: 'start_swiping',
        label: 'Start Swiping',
        icon: '💘',
        action: () => {
          closeCommandPalette();
          analytics.click('contextual_action', 'start_swiping');
        },
        keywords: ['swipe', 'start'],
      });
      actions.push({
        id: 'view_matches',
        label: 'View My Matches',
        icon: '🎯',
        action: () => navigateToPage('/saved', 'saved'),
        keywords: ['matches', 'liked'],
      });
    }

    // Search page
    if (pathname === '/search') {
      actions.push({
        id: 'filter_properties',
        label: 'Filter Properties',
        icon: '⚙️',
        action: () => {
          closeCommandPalette();
          analytics.click('contextual_action', 'filter_properties');
        },
        keywords: ['filter', 'refine'],
      });
      actions.push({
        id: 'map_view',
        label: 'Map View',
        icon: '🗺️',
        action: () => {
          closeCommandPalette();
          analytics.click('contextual_action', 'map_view');
        },
        keywords: ['map', 'location'],
      });
    }

    // Saved page
    if (pathname === '/saved') {
      actions.push({
        id: 'compare_saved',
        label: 'Compare Saved',
        icon: '⚖️',
        action: () => {
          analytics.click('contextual_action', 'compare_saved');
        },
        keywords: ['compare', 'side by side'],
      });
      actions.push({
        id: 'share_list',
        label: 'Share My List',
        icon: '↗️',
        action: () => {
          if (navigator.share) {
            navigator.share({ title: 'My saved properties', url: window.location.href });
          }
          analytics.click('contextual_action', 'share_list');
        },
        keywords: ['share', 'send'],
      });
    }

    return actions;
  };

  const getQuickActions = (): QuickAction[] => {
    return [
      {
        id: 'search_properties',
        label: 'Search Properties',
        icon: '🔍',
        action: () => navigateToPage('/search', 'search'),
        keywords: ['search', 'find', 'properties', 'apartments'],
      },
      {
        id: 'start_swiping',
        label: 'Start Swiping',
        icon: '💘',
        action: () => navigateToPage('/matchmaker', 'matchmaker'),
        keywords: ['swipe', 'matchmaker', 'like', 'train'],
      },
      {
        id: 'view_saved',
        label: 'View Saved Properties',
        icon: '❤️',
        action: () => navigateToPage('/saved', 'saved'),
        keywords: ['saved', 'favorites', 'liked'],
      },
      {
        id: 'upload_document',
        label: 'Upload Document',
        icon: '📤',
        action: () => navigateToPage('/vault', 'vault'),
        keywords: ['upload', 'document', 'vault', 'lease'],
      },
      {
        id: 'find_agent',
        label: 'Find an Agent',
        icon: '🏢',
        action: () => navigateToPage('/directory', 'directory'),
        keywords: ['agent', 'directory', 'realtor', 'contact'],
      },
    ];
  };

  const getSearchResults = (): SearchResult[] => {
    if (!query.trim()) return [];

    const lowerQuery = query.toLowerCase();
    const results: SearchResult[] = [];

    // Search pages
    PAGES.forEach(page => {
      const matchesName = page.name.toLowerCase().includes(lowerQuery);
      const matchesKeywords = page.keywords.some(k => k.includes(lowerQuery));
      const matchesDescription = page.description.toLowerCase().includes(lowerQuery);

      if (matchesName || matchesKeywords || matchesDescription) {
        results.push({
          id: page.id,
          type: 'page',
          label: page.name,
          sublabel: page.description,
          icon: page.icon,
          action: () => navigateToPage(page.path, page.id),
        });
      }
    });

    // Search quick actions
    getQuickActions().forEach(action => {
      const matches = action.keywords.some(k => k.includes(lowerQuery)) ||
                     action.label.toLowerCase().includes(lowerQuery);

      if (matches) {
        results.push({
          id: action.id,
          type: 'action',
          label: action.label,
          icon: action.icon,
          action: action.action,
        });
      }
    });

    // Natural language patterns
    if (lowerQuery.includes('under') && lowerQuery.includes('$')) {
      results.push({
        id: 'nl_price_search',
        type: 'action',
        label: `Search properties ${query}`,
        sublabel: 'Natural language search',
        icon: '🤖',
        action: () => {
          navigateToPage('/search', 'search');
          // TODO: Apply price filter based on query
        },
      });
    }

    if (lowerQuery.includes('apartment') || lowerQuery.includes('property')) {
      results.push({
        id: 'nl_property_search',
        type: 'action',
        label: 'Search all properties',
        sublabel: 'View available listings',
        icon: '🏠',
        action: () => navigateToPage('/search', 'search'),
      });
    }

    return results;
  };

  const getFrequentPagesSuggestions = () => {
    return frequentPages
      .map(({ page }) => PAGES.find(p => p.id === page))
      .filter(Boolean) as Page[];
  };

  const getRecentPagesSuggestions = () => {
    return recentPages
      .map(pageId => PAGES.find(p => p.id === pageId))
      .filter(Boolean) as Page[];
  };

  const searchResults = getSearchResults();
  const frequentSuggestions = getFrequentPagesSuggestions();
  const recentSuggestions = getRecentPagesSuggestions();
  const quickActions = getQuickActions();
  const contextualActions = getContextualActions();

  return (
    <>
      {/* Command Palette Overlay */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            className="fixed inset-0 z-[300] bg-black/50 backdrop-blur-md flex items-start justify-center pt-20 px-4"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={closeCommandPalette}
          >
            <motion.div
              className="w-full max-w-2xl bg-gradient-to-b from-gray-900 to-black rounded-2xl shadow-2xl border border-white/10 overflow-hidden"
              initial={{ opacity: 0, y: -20, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -20, scale: 0.95 }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Search Input */}
              <div className="p-6 border-b border-white/10">
                <div className="relative">
                  <input
                    ref={inputRef}
                    type="text"
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder="Search pages, properties, documents, or type anything..."
                    className="w-full px-6 py-4 bg-white/5 border border-white/20 rounded-xl text-white text-lg placeholder-white/40 focus:outline-none focus:border-primary/50"
                  />
                  <div className="absolute right-4 top-1/2 -translate-y-1/2 flex items-center gap-2">
                    {query && (
                      <button
                        onClick={() => setQuery('')}
                        className="min-w-[44px] min-h-[44px] flex items-center justify-center text-white/40 hover:text-white"
                      >
                        ✕
                      </button>
                    )}
                    <span className="text-2xl">🔍</span>
                  </div>
                </div>
                <div className="mt-3 flex items-center gap-2 text-xs text-white/40">
                  <kbd className="px-2 py-1 bg-white/10 rounded">⌘K</kbd>
                  <span>to open</span>
                  <kbd className="px-2 py-1 bg-white/10 rounded ml-2">ESC</kbd>
                  <span>to close</span>
                </div>
              </div>

              {/* Results */}
              <div className="max-h-[60vh] overflow-y-auto">
                {query.trim() ? (
                  // Search Results
                  <div className="p-4">
                    {searchResults.length === 0 ? (
                      <div className="py-12 text-center">
                        <div className="text-6xl mb-4">🤔</div>
                        <p className="text-white/60">No results found</p>
                        <p className="text-white/40 text-sm mt-2">Try a different search term</p>
                      </div>
                    ) : (
                      <div className="space-y-2">
                        <h3 className="text-xs font-bold text-white/40 uppercase tracking-wider mb-3 px-2">
                          Results ({searchResults.length})
                        </h3>
                        {searchResults.map((result, idx) => (
                          <motion.button
                            key={result.id}
                            onClick={result.action}
                            className="w-full p-4 min-h-[44px] bg-white/5 hover:bg-white/10 rounded-xl text-left transition-colors flex items-center gap-4"
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: idx * 0.05 }}
                            whileHover={{ x: 4 }}
                          >
                            <span className="text-3xl">{result.icon}</span>
                            <div className="flex-1">
                              <div className="text-white font-semibold">{result.label}</div>
                              {result.sublabel && (
                                <div className="text-white/60 text-sm mt-1">{result.sublabel}</div>
                              )}
                            </div>
                            <span className="text-white/40">→</span>
                          </motion.button>
                        ))}
                      </div>
                    )}
                  </div>
                ) : (
                  // Default View: All Pages Only
                  <div className="p-6">
                    <div className="grid grid-cols-3 gap-3">
                      {PAGES.map((page) => (
                        <motion.button
                          key={page.id}
                          onClick={() => navigateToPage(page.path, page.id)}
                          className="p-4 min-h-[44px] min-w-[44px] bg-white/5 hover:bg-white/10 rounded-xl text-center transition-colors"
                          whileHover={{ scale: 1.05 }}
                          whileTap={{ scale: 0.95 }}
                        >
                          <div className="text-3xl mb-2">{page.icon}</div>
                          <div className="text-white text-xs font-semibold">{page.name}</div>
                        </motion.button>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
