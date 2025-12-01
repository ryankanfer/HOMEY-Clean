'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import CinematicBackground from '@/components/CinematicBackground';
import DesignCard from '@/components/DesignCard';
import MoodBoardView from '@/components/MoodBoardView';
import BottomNav from '@/components/BottomNav';

interface DesignInspiration {
  id: string;
  image_url: string;
  title?: string;
  description?: string;
  room_type?: string;
  style_tags?: string[];
  color_palette?: string[];
}

export default function StyleStudioPage() {
  const router = useRouter();
  const [designs, setDesigns] = useState<DesignInspiration[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [userId, setUserId] = useState<string | null>(null);
  const [stats, setStats] = useState({ total: 0, likes: 0, loves: 0, passes: 0 });
  const [showOnboarding, setShowOnboarding] = useState(true);
  const [showMoodBoards, setShowMoodBoards] = useState(false);
  const [showBoardSelector, setShowBoardSelector] = useState(false);
  const [pendingLoveDesign, setPendingLoveDesign] = useState<string | null>(null);
  const [userBoards, setUserBoards] = useState<any[]>([]);
  const [styleProfile, setStyleProfile] = useState<any>(null);
  const [showStyleProfile, setShowStyleProfile] = useState(false);
  const [aiLearning, setAiLearning] = useState(false);

  useEffect(() => {
    analytics.pageView('style_studio');
    initStudio();
  }, []);

  const initStudio = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        router.push('/');
        return;
      }

      setUserId(user.id);

      // Load unswiped designs
      // @ts-ignore
      const { data: unswipedDesigns, error } = await db.getUnswipedDesigns(user.id, 30);

      if (error) throw error;

      if (unswipedDesigns && unswipedDesigns.length > 0) {
        setDesigns(unswipedDesigns);
      }

      // Load stats
      // @ts-ignore
      const { data: swipeStats } = await db.getDesignSwipeStats(user.id);
      if (swipeStats) {
        setStats(swipeStats);
        if (swipeStats.total > 0) {
          setShowOnboarding(false);
        }
      }

      // Load user's mood boards
      // @ts-ignore
      const { data: boards } = await db.getUserMoodBoards(user.id);
      if (boards) {
        setUserBoards(boards);
      }

      // Generate style profile if user has enough swipes
      if (swipeStats && swipeStats.total >= 10) {
        await generateStyleProfile(user.id);
      }

      setLoading(false);
    } catch (err) {
      console.error('Failed to initialize style studio:', err);
      setLoading(false);
    }
  };

  const generateStyleProfile = async (uid: string) => {
    try {
      // Get user's liked and loved designs
      // @ts-ignore
      const { data: likedDesigns } = await db.getLikedDesigns(uid);

      if (!likedDesigns || likedDesigns.length === 0) return;

      // Analyze style tags
      const styleCount: Record<string, number> = {};
      const roomCount: Record<string, number> = {};
      const colorCount: Record<string, number> = {};

      likedDesigns.forEach((design: any) => {
        // Count style tags
        design.style_tags?.forEach((tag: string) => {
          styleCount[tag] = (styleCount[tag] || 0) + 1;
        });

        // Count room types
        if (design.room_type) {
          roomCount[design.room_type] = (roomCount[design.room_type] || 0) + 1;
        }

        // Count colors
        design.color_palette?.forEach((color: string) => {
          colorCount[color] = (colorCount[color] || 0) + 1;
        });
      });

      // Get top 3 of each
      const topStyles = Object.entries(styleCount)
        .sort(([, a], [, b]) => (b as number) - (a as number))
        .slice(0, 3)
        .map(([style]) => style);

      const topRooms = Object.entries(roomCount)
        .sort(([, a], [, b]) => (b as number) - (a as number))
        .slice(0, 3)
        .map(([room]) => room);

      const topColors = Object.entries(colorCount)
        .sort(([, a], [, b]) => (b as number) - (a as number))
        .slice(0, 3)
        .map(([color]) => color);

      setStyleProfile({
        topStyles,
        topRooms,
        topColors,
        totalSaved: likedDesigns.length,
      });
    } catch (err) {
      console.error('Failed to generate style profile:', err);
    }
  };

  const handleSwipe = async (direction: 'left' | 'right' | 'up') => {
    if (!userId || currentIndex >= designs.length) return;

    const currentDesign = designs[currentIndex];
    const action = direction === 'left' ? 'pass' : direction === 'right' ? 'like' : 'love';

    // Show AI learning
    if (action !== 'pass') {
      setAiLearning(true);
      setTimeout(() => setAiLearning(false), 1500);
    }

    // Record swipe
    // @ts-ignore
    const { data, error } = await db.recordDesignSwipe(userId, currentDesign.id, action);
    if (error) {
      console.error('Failed to record design swipe:', error);
      console.error('Design swipe details:', { userId, designId: currentDesign.id, action });
    } else {
      console.log('Design swipe recorded successfully:', { userId, designId: currentDesign.id, action });
    }

    // Track analytics
    analytics.click(`swipe_design_${action}`, 'card', {
      design_id: currentDesign.id,
      room_type: currentDesign.room_type,
      style_tags: currentDesign.style_tags,
    });

    // Update stats
    const newStats = {
      total: stats.total + 1,
      likes: stats.likes + (action === 'like' ? 1 : 0),
      loves: stats.loves + (action === 'love' ? 1 : 0),
      passes: stats.passes + (action === 'pass' ? 1 : 0),
    };
    setStats(newStats);

    // Regenerate style profile if we hit milestones
    if (newStats.total === 10 || newStats.total % 20 === 0) {
      await generateStyleProfile(userId);
    }

    // Handle "love" - add to mood board
    if (action === 'love') {
      if (userBoards.length === 0) {
        // Create default board and add design to it
        // @ts-ignore
        const { data: newBoard } = await db.createMoodBoard(userId, 'My Favorites', 'My favorite design inspirations');
        if (newBoard) {
          // @ts-ignore
          await db.addToMoodBoard(newBoard.id, currentDesign.id);
          setUserBoards([newBoard]);
        }
      } else if (userBoards.length === 1) {
        // Add to the only board automatically
        // @ts-ignore
        await db.addToMoodBoard(userBoards[0].id, currentDesign.id);
      } else {
        // Show board selector
        setPendingLoveDesign(currentDesign.id);
        setShowBoardSelector(true);
        return; // Don't advance card yet
      }
    }

    // Move to next card
    setTimeout(() => {
      setCurrentIndex(prev => prev + 1);
    }, 300);
  };

  const handleSelectBoardForLove = async (boardId: string) => {
    if (!pendingLoveDesign) return;

    // @ts-ignore
    await db.addToMoodBoard(boardId, pendingLoveDesign);
    setPendingLoveDesign(null);
    setShowBoardSelector(false);

    // Move to next card
    setTimeout(() => {
      setCurrentIndex(prev => prev + 1);
    }, 300);
  };

  const handleButtonSwipe = (direction: 'left' | 'right' | 'up') => {
    handleSwipe(direction);
  };

  const currentDesign = designs[currentIndex];
  const remainingCount = designs.length - currentIndex;

  if (loading) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="text-white text-2xl">Loading inspiration...</div>
      </main>
    );
  }

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/80 via-black/60 to-transparent backdrop-blur-md">
        <div className="px-5 py-4">
          <div className="flex items-center justify-between">
            <button
              onClick={() => router.back()}
              className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
            >
              ←
            </button>
            <div className="text-center">
              <div className="flex items-center gap-2 justify-center">
                <h1 className="text-xl font-bold text-white">Style Studio</h1>
                {styleProfile && (
                  <motion.div
                    className="px-2 py-1 bg-primary/20 rounded-full text-xs font-bold text-primary border border-primary/30 cursor-pointer"
                    onClick={() => setShowStyleProfile(true)}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    Profile
                  </motion.div>
                )}
              </div>
              <p className="text-xs text-white/60">{remainingCount} remaining</p>
            </div>
            <button
              onClick={() => setShowMoodBoards(!showMoodBoards)}
              className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
            >
              📋
            </button>
          </div>
        </div>

        {/* AI Learning Indicator */}
        <AnimatePresence>
          {aiLearning && (
            <motion.div
              className="mx-5 mb-3 p-3 bg-primary/20 border border-primary/30 rounded-xl backdrop-blur-sm"
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
            >
              <div className="flex items-center gap-2">
                <motion.div
                  className="w-2 h-2 rounded-full bg-primary"
                  animate={{ opacity: [0.5, 1, 0.5] }}
                  transition={{ duration: 1, repeat: Infinity }}
                />
                <span className="text-white text-sm font-semibold">
                  Learning your design style...
                </span>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* Onboarding Overlay */}
      <AnimatePresence>
        {showOnboarding && (
          <motion.div
            className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm px-5"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <motion.div
              className="max-w-md w-full glass-strong rounded-3xl p-8 text-center"
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              transition={{ delay: 0.1 }}
            >
              <div className="text-6xl mb-4">🎨</div>
              <h2 className="text-3xl font-bold text-white mb-4">Discover Your Style</h2>
              <p className="text-white/80 mb-8">
                Swipe through beautiful interiors to build your design profile. Save favorites to mood boards!
              </p>

              <div className="space-y-4 mb-8">
                <div className="flex items-center gap-4 text-left">
                  <div className="w-12 h-12 rounded-full bg-red-500/20 flex items-center justify-center text-2xl">←</div>
                  <div>
                    <div className="text-white font-bold">Swipe Left</div>
                    <div className="text-white/60 text-sm">Not my style</div>
                  </div>
                </div>
                <div className="flex items-center gap-4 text-left">
                  <div className="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center text-2xl">→</div>
                  <div>
                    <div className="text-white font-bold">Swipe Right</div>
                    <div className="text-white/60 text-sm">I like this</div>
                  </div>
                </div>
                <div className="flex items-center gap-4 text-left">
                  <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center text-2xl">↑</div>
                  <div>
                    <div className="text-white font-bold">Swipe Up</div>
                    <div className="text-white/60 text-sm">Save to mood board</div>
                  </div>
                </div>
              </div>

              <button
                onClick={() => setShowOnboarding(false)}
                className="w-full px-8 py-4 bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white rounded-full font-bold hover:scale-105 transition-all"
              >
                Start Discovering
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Design Cards */}
      <div className="relative z-10 pt-24 px-5">
        {remainingCount === 0 ? (
          <motion.div
            className="h-[600px] flex flex-col items-center justify-center text-center"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
          >
            <div className="text-8xl mb-6">✨</div>
            <h2 className="text-4xl font-bold text-white mb-4">You've Discovered It All!</h2>
            <p className="text-xl text-white/80 mb-8">
              You've explored all available designs.
            </p>
            <div className="glass-strong rounded-2xl p-6 mb-8">
              <div className="grid grid-cols-3 gap-6 text-center">
                <div>
                  <div className="text-3xl font-bold text-white">{stats.loves}</div>
                  <div className="text-white/60 text-sm">Saved</div>
                </div>
                <div>
                  <div className="text-3xl font-bold text-white">{stats.likes}</div>
                  <div className="text-white/60 text-sm">Liked</div>
                </div>
                <div>
                  <div className="text-3xl font-bold text-white">{stats.passes}</div>
                  <div className="text-white/60 text-sm">Passed</div>
                </div>
              </div>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => router.push('/home')}
                className="px-8 py-4 bg-white text-black rounded-full font-bold hover:bg-white/90 transition-colors"
              >
                Back to Home
              </button>
              <button
                onClick={() => setShowMoodBoards(true)}
                className="px-8 py-4 bg-primary text-white rounded-full font-bold hover:bg-primary/90 transition-colors"
              >
                View Mood Boards
              </button>
            </div>
          </motion.div>
        ) : (
          <>
            {/* Card Stack */}
            <div className="relative h-[600px] max-w-md mx-auto">
              <AnimatePresence>
                {designs.slice(currentIndex, currentIndex + 3).map((design, index) => (
                  <DesignCard
                    key={design.id}
                    design={design}
                    onSwipe={index === 0 ? handleSwipe : () => {}}
                    style={{
                      zIndex: 3 - index,
                      scale: 1 - index * 0.05,
                      y: index * 10,
                      opacity: 1 - index * 0.3,
                      pointerEvents: index === 0 ? 'auto' : 'none',
                    }}
                  />
                ))}
              </AnimatePresence>
            </div>

            {/* Action Buttons */}
            <div className="flex items-center justify-center gap-4 mt-8">
              <button
                onClick={() => handleButtonSwipe('left')}
                className="w-16 h-16 rounded-full bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center text-3xl transition-colors border-2 border-red-500/50"
              >
                ✕
              </button>
              <button
                onClick={() => handleButtonSwipe('up')}
                className="w-20 h-20 rounded-full bg-primary/20 hover:bg-primary/30 flex items-center justify-center text-4xl transition-colors border-2 border-primary/50"
              >
                💕
              </button>
              <button
                onClick={() => handleButtonSwipe('right')}
                className="w-16 h-16 rounded-full bg-green-500/20 hover:bg-green-500/30 flex items-center justify-center text-3xl transition-colors border-2 border-green-500/50"
              >
                ✓
              </button>
            </div>

            {/* Stats */}
            <div className="flex items-center justify-center gap-6 mt-6 text-white/60 text-sm">
              <span>{stats.total} total</span>
              <span>•</span>
              <span>{stats.loves} 💕 saved</span>
              <span>•</span>
              <span>{stats.likes} liked</span>
            </div>
          </>
        )}
      </div>

      {/* Mood Board View */}
      <AnimatePresence>
        {showMoodBoards && userId && (
          <MoodBoardView
            userId={userId}
            onClose={() => setShowMoodBoards(false)}
          />
        )}
      </AnimatePresence>

      {/* Board Selector Modal */}
      <AnimatePresence>
        {showBoardSelector && (
          <motion.div
            className="fixed inset-0 z-[150] flex items-center justify-center bg-black/50 backdrop-blur-sm px-5"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => {
              setShowBoardSelector(false);
              setPendingLoveDesign(null);
              setTimeout(() => setCurrentIndex(prev => prev + 1), 300);
            }}
          >
            <motion.div
              className="max-w-md w-full glass-strong rounded-3xl p-6"
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.9, y: 20 }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="text-center mb-6">
                <div className="text-5xl mb-3">💕</div>
                <h2 className="text-2xl font-bold text-white mb-2">Save to Board</h2>
                <p className="text-white/60 text-sm">Choose a mood board for this design</p>
              </div>

              <div className="space-y-3 max-h-[400px] overflow-y-auto mb-6">
                {userBoards.map((board) => (
                  <button
                    key={board.id}
                    onClick={() => handleSelectBoardForLove(board.id)}
                    className="w-full p-4 rounded-xl bg-white/10 hover:bg-white/20 border border-white/20 hover:border-primary transition-all text-left"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-12 h-12 rounded-lg bg-gradient-to-br from-primary/30 to-purple-600/30 flex items-center justify-center text-2xl">
                        📋
                      </div>
                      <div className="flex-1">
                        <div className="text-white font-bold">{board.name}</div>
                        {board.description && (
                          <div className="text-white/60 text-xs mt-1 line-clamp-1">
                            {board.description}
                          </div>
                        )}
                      </div>
                    </div>
                  </button>
                ))}
              </div>

              <button
                onClick={() => {
                  setShowBoardSelector(false);
                  setPendingLoveDesign(null);
                  setTimeout(() => setCurrentIndex(prev => prev + 1), 300);
                }}
                className="w-full px-6 py-3 rounded-xl bg-white/10 text-white font-medium hover:bg-white/20 transition-colors"
              >
                Skip for Now
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
