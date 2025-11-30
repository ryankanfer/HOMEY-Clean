'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { db } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';

interface MoodBoard {
  id: string;
  name: string;
  description?: string;
  cover_image_url?: string;
  items?: { count: number }[];
  created_at: string;
  updated_at: string;
}

interface DesignInspiration {
  id: string;
  image_url: string;
  title?: string;
  description?: string;
  room_type?: string;
  style_tags?: string[];
}

interface MoodBoardItemWithInspiration {
  id: string;
  inspiration: DesignInspiration;
  notes?: string;
  created_at: string;
}

interface MoodBoardViewProps {
  userId: string;
  onClose: () => void;
}

export default function MoodBoardView({ userId, onClose }: MoodBoardViewProps) {
  const [boards, setBoards] = useState<MoodBoard[]>([]);
  const [selectedBoard, setSelectedBoard] = useState<MoodBoard | null>(null);
  const [boardItems, setBoardItems] = useState<MoodBoardItemWithInspiration[]>([]);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newBoardName, setNewBoardName] = useState('');
  const [newBoardDescription, setNewBoardDescription] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    analytics.pageView('mood_boards');
    loadBoards();
  }, []);

  const loadBoards = async () => {
    try {
      const { data, error } = await db.getUserMoodBoards(userId);
      if (error) throw error;
      setBoards(data || []);
      setLoading(false);
    } catch (err) {
      console.error('Failed to load mood boards:', err);
      setLoading(false);
    }
  };

  const loadBoardItems = async (boardId: string) => {
    try {
      const { data, error } = await db.getMoodBoardItems(boardId);
      if (error) throw error;
      setBoardItems(data || []);
    } catch (err) {
      console.error('Failed to load board items:', err);
    }
  };

  const handleCreateBoard = async () => {
    if (!newBoardName.trim()) return;

    try {
      const { data, error } = await db.createMoodBoard(
        userId,
        newBoardName.trim(),
        newBoardDescription.trim() || undefined
      );

      if (error) throw error;

      analytics.click('create_mood_board', 'button', { name: newBoardName });

      setBoards(prev => [data, ...prev]);
      setNewBoardName('');
      setNewBoardDescription('');
      setShowCreateModal(false);
    } catch (err) {
      console.error('Failed to create mood board:', err);
      alert('Failed to create mood board. Please try again.');
    }
  };

  const handleSelectBoard = (board: MoodBoard) => {
    setSelectedBoard(board);
    loadBoardItems(board.id);
    analytics.click('view_mood_board', 'card', { board_id: board.id });
  };

  const getItemCount = (board: MoodBoard) => {
    return board.items && board.items.length > 0 ? board.items[0].count : 0;
  };

  if (loading) {
    return (
      <motion.div
        className="fixed inset-0 z-[200] bg-black/90 backdrop-blur-md flex items-center justify-center"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
      >
        <div className="text-white text-xl">Loading mood boards...</div>
      </motion.div>
    );
  }

  return (
    <motion.div
      className="fixed inset-0 z-[200] bg-black/90 backdrop-blur-md overflow-y-auto"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
    >
      <div className="min-h-screen px-5 py-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold text-white">Mood Boards</h1>
            <p className="text-white/60 text-sm mt-1">
              {boards.length} {boards.length === 1 ? 'board' : 'boards'}
            </p>
          </div>
          <button
            onClick={onClose}
            className="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white text-xl transition-colors"
          >
            ✕
          </button>
        </div>

        {/* Board List View */}
        {!selectedBoard && (
          <>
            {/* Create New Board Button */}
            <motion.button
              onClick={() => setShowCreateModal(true)}
              className="w-full mb-6 p-6 rounded-2xl bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white font-bold text-lg hover:scale-105 transition-transform"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              + Create New Board
            </motion.button>

            {/* Boards Grid */}
            {boards.length === 0 ? (
              <motion.div
                className="text-center py-20"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
              >
                <div className="text-6xl mb-4">📋</div>
                <h3 className="text-2xl font-bold text-white mb-2">No Mood Boards Yet</h3>
                <p className="text-white/60 mb-6">
                  Create your first board to start organizing your design inspiration
                </p>
              </motion.div>
            ) : (
              <div className="grid grid-cols-2 gap-4">
                {boards.map((board, index) => (
                  <motion.div
                    key={board.id}
                    className="aspect-square rounded-2xl overflow-hidden bg-gradient-to-br from-white/10 to-white/5 backdrop-blur-sm cursor-pointer hover:scale-105 transition-transform"
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: index * 0.05 }}
                    onClick={() => handleSelectBoard(board)}
                  >
                    {board.cover_image_url ? (
                      <img
                        src={board.cover_image_url}
                        alt={board.name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-primary/20 to-purple-600/20">
                        <span className="text-6xl">🎨</span>
                      </div>
                    )}
                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent flex flex-col justify-end p-4">
                      <h3 className="text-white font-bold text-lg mb-1">{board.name}</h3>
                      <p className="text-white/60 text-xs">
                        {getItemCount(board)} {getItemCount(board) === 1 ? 'item' : 'items'}
                      </p>
                    </div>
                  </motion.div>
                ))}
              </div>
            )}
          </>
        )}

        {/* Board Detail View */}
        {selectedBoard && (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
          >
            {/* Back Button */}
            <button
              onClick={() => setSelectedBoard(null)}
              className="flex items-center gap-2 text-white/80 hover:text-white mb-6 transition-colors"
            >
              <span className="text-xl">←</span>
              <span>Back to Boards</span>
            </button>

            {/* Board Header */}
            <div className="glass-strong rounded-2xl p-6 mb-6">
              <h2 className="text-2xl font-bold text-white mb-2">{selectedBoard.name}</h2>
              {selectedBoard.description && (
                <p className="text-white/80 mb-4">{selectedBoard.description}</p>
              )}
              <div className="flex items-center gap-4 text-white/60 text-sm">
                <span>{boardItems.length} items</span>
                <span>•</span>
                <span>
                  Created {new Date(selectedBoard.created_at).toLocaleDateString()}
                </span>
              </div>
            </div>

            {/* Board Items Grid */}
            {boardItems.length === 0 ? (
              <div className="text-center py-20">
                <div className="text-6xl mb-4">💕</div>
                <h3 className="text-2xl font-bold text-white mb-2">Board is Empty</h3>
                <p className="text-white/60">
                  Swipe up (save) on designs in the Style Studio to add them here
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-2 gap-4">
                {boardItems.map((item, index) => (
                  <motion.div
                    key={item.id}
                    className="aspect-square rounded-2xl overflow-hidden bg-white/5 backdrop-blur-sm"
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: index * 0.03 }}
                  >
                    <img
                      src={item.inspiration.image_url}
                      alt={item.inspiration.title || 'Design inspiration'}
                      className="w-full h-full object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-0 hover:opacity-100 transition-opacity flex flex-col justify-end p-4">
                      {item.inspiration.title && (
                        <h4 className="text-white font-bold text-sm mb-1">
                          {item.inspiration.title}
                        </h4>
                      )}
                      {item.inspiration.style_tags && item.inspiration.style_tags.length > 0 && (
                        <div className="flex flex-wrap gap-1">
                          {item.inspiration.style_tags.slice(0, 2).map((tag, i) => (
                            <span
                              key={i}
                              className="px-2 py-1 bg-white/20 rounded-full text-white text-xs"
                            >
                              {tag}
                            </span>
                          ))}
                        </div>
                      )}
                    </div>
                  </motion.div>
                ))}
              </div>
            )}
          </motion.div>
        )}

        {/* Create Board Modal */}
        <AnimatePresence>
          {showCreateModal && (
            <motion.div
              className="fixed inset-0 z-[300] flex items-center justify-center bg-black/50 backdrop-blur-sm px-5"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowCreateModal(false)}
            >
              <motion.div
                className="max-w-md w-full glass-strong rounded-3xl p-8"
                initial={{ scale: 0.9, y: 20 }}
                animate={{ scale: 1, y: 0 }}
                exit={{ scale: 0.9, y: 20 }}
                onClick={(e) => e.stopPropagation()}
              >
                <h2 className="text-2xl font-bold text-white mb-6">Create New Board</h2>

                <div className="space-y-4 mb-6">
                  <div>
                    <label className="block text-white/80 text-sm mb-2">Board Name</label>
                    <input
                      type="text"
                      value={newBoardName}
                      onChange={(e) => setNewBoardName(e.target.value)}
                      placeholder="e.g., Living Room Ideas"
                      className="w-full px-4 py-3 rounded-xl bg-white/10 border border-white/20 text-white placeholder-white/40 focus:outline-none focus:border-primary transition-colors"
                      maxLength={50}
                    />
                  </div>

                  <div>
                    <label className="block text-white/80 text-sm mb-2">
                      Description (optional)
                    </label>
                    <textarea
                      value={newBoardDescription}
                      onChange={(e) => setNewBoardDescription(e.target.value)}
                      placeholder="Add a description..."
                      className="w-full px-4 py-3 rounded-xl bg-white/10 border border-white/20 text-white placeholder-white/40 focus:outline-none focus:border-primary transition-colors resize-none"
                      rows={3}
                      maxLength={200}
                    />
                  </div>
                </div>

                <div className="flex gap-3">
                  <button
                    onClick={() => setShowCreateModal(false)}
                    className="flex-1 px-6 py-3 rounded-xl bg-white/10 text-white font-medium hover:bg-white/20 transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleCreateBoard}
                    disabled={!newBoardName.trim()}
                    className="flex-1 px-6 py-3 rounded-xl bg-gradient-to-r from-primary to-purple-500 text-white font-bold hover:scale-105 transition-transform disabled:opacity-50 disabled:hover:scale-100"
                  >
                    Create Board
                  </button>
                </div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </motion.div>
  );
}
