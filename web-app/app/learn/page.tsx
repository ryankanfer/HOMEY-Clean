'use client';

export const dynamic = 'force-dynamic';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';

interface Course {
  id: string;
  title: string;
  description: string;
  instructor: string;
  duration: string;
  lessons: number;
  category: 'First-Time Buyer' | 'Renting' | 'Investing' | 'Neighborhoods' | 'Financing';
  thumbnail: string;
  progress?: number;
  difficulty: 'Beginner' | 'Intermediate' | 'Advanced';
}

const courses: Course[] = [
  {
    id: 'first-time-buyer-101',
    title: 'First-Time Home Buyer Essentials',
    description: 'Learn everything you need to know about buying your first home, from budgeting to closing.',
    instructor: 'Sarah Chen, Real Estate Expert',
    duration: '2h 30min',
    lessons: 12,
    category: 'First-Time Buyer',
    thumbnail: '🏡',
    difficulty: 'Beginner',
  },
  {
    id: 'neighborhood-research',
    title: 'Mastering Neighborhood Research',
    description: 'Discover how to evaluate neighborhoods like a pro and find the perfect community for your lifestyle.',
    instructor: 'Marcus Williams, Urban Planner',
    duration: '1h 45min',
    lessons: 8,
    category: 'Neighborhoods',
    thumbnail: '📍',
    difficulty: 'Beginner',
  },
  {
    id: 'renting-101',
    title: 'The Smart Renter\'s Guide',
    description: 'Navigate the rental market with confidence. Learn negotiation tactics and lease review essentials.',
    instructor: 'Emma Rodriguez, Tenant Rights Advocate',
    duration: '1h 15min',
    lessons: 6,
    category: 'Renting',
    thumbnail: '🔑',
    difficulty: 'Beginner',
  },
  {
    id: 'mortgage-mastery',
    title: 'Mortgage & Financing Mastery',
    description: 'Understand different mortgage types, calculate what you can afford, and get the best rates.',
    instructor: 'David Park, Mortgage Broker',
    duration: '3h 00min',
    lessons: 15,
    category: 'Financing',
    thumbnail: '💰',
    difficulty: 'Intermediate',
  },
  {
    id: 'investment-properties',
    title: 'Real Estate Investment Fundamentals',
    description: 'Learn how to analyze investment properties, calculate ROI, and build wealth through real estate.',
    instructor: 'Jessica Thompson, Real Estate Investor',
    duration: '4h 15min',
    lessons: 20,
    category: 'Investing',
    thumbnail: '📈',
    difficulty: 'Advanced',
  },
  {
    id: 'home-inspection',
    title: 'Home Inspection Deep Dive',
    description: 'Know what to look for during inspections and how to identify red flags before making an offer.',
    instructor: 'Robert Kim, Licensed Home Inspector',
    duration: '2h 00min',
    lessons: 10,
    category: 'First-Time Buyer',
    thumbnail: '🔍',
    difficulty: 'Intermediate',
  },
];

export default function EducationCenterPage() {
  const router = useRouter();
  const [userId, setUserId] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('All');
  const [userProgress, setUserProgress] = useState<{ [key: string]: number }>({});

  const categories = ['All', 'First-Time Buyer', 'Renting', 'Investing', 'Neighborhoods', 'Financing'];

  useEffect(() => {
    loadUser();
    analytics.pageView('education_center');
  }, []);

  const loadUser = async () => {
    const { data: { user } } = await auth.getUser();
    if (user) {
      setUserId(user.id);
      // TODO: Load user's course progress from database
      // For now, using mock data
      setUserProgress({
        'first-time-buyer-101': 35,
        'neighborhood-research': 75,
      });
    }
  };

  const filteredCourses = selectedCategory === 'All'
    ? courses
    : courses.filter(course => course.category === selectedCategory);

  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case 'Beginner':
        return 'text-green-400';
      case 'Intermediate':
        return 'text-yellow-400';
      case 'Advanced':
        return 'text-orange-400';
      default:
        return 'text-white';
    }
  };

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/80 via-black/60 to-transparent backdrop-blur-md">
        <div className="px-5 py-4">
          <div className="flex items-center justify-between mb-4">
            <button
              onClick={() => router.back()}
              className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
            >
              ←
            </button>
            <h1 className="text-xl font-bold text-white">Education Center</h1>
            <div className="w-10" /> {/* Spacer */}
          </div>

          {/* Hero */}
          <div className="mb-6">
            <h2 className="text-3xl font-bold text-white mb-2">
              Master the Art of Finding Home
            </h2>
            <p className="text-white/80">
              Learn from industry experts with our MasterClass-style courses
            </p>
          </div>

          {/* Category Filter */}
          <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
            {categories.map(category => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-4 py-2 rounded-full font-semibold whitespace-nowrap transition-all ${
                  selectedCategory === category
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white/80 hover:bg-white/20'
                }`}
              >
                {category}
              </button>
            ))}
          </div>
        </div>
      </header>

      {/* Courses Grid */}
      <div className="relative z-10 pt-64 px-5 max-w-7xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredCourses.map((course, index) => {
            const progress = userProgress[course.id] || 0;
            const isStarted = progress > 0;

            return (
              <motion.div
                key={course.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: index * 0.1 }}
              >
                <div
                  onClick={() => {
                    analytics.click('start_course', 'card', { course_id: course.id });
                    router.push(`/learn/${course.id}`);
                  }}
                  className="glass-strong rounded-2xl overflow-hidden cursor-pointer group hover:scale-[1.02] transition-transform"
                >
                  {/* Thumbnail */}
                  <div className="relative h-48 bg-gradient-to-br from-primary/30 to-purple-600/30 flex items-center justify-center">
                    <span className="text-8xl group-hover:scale-110 transition-transform">
                      {course.thumbnail}
                    </span>

                    {/* Difficulty Badge */}
                    <div className="absolute top-4 right-4">
                      <span className={`px-3 py-1 rounded-full text-xs font-bold glass-strong ${getDifficultyColor(course.difficulty)}`}>
                        {course.difficulty}
                      </span>
                    </div>

                    {/* Progress Indicator */}
                    {isStarted && (
                      <div className="absolute bottom-0 left-0 right-0 h-2 bg-black/40">
                        <div
                          className="h-full bg-primary transition-all duration-300"
                          style={{ width: `${progress}%` }}
                        />
                      </div>
                    )}
                  </div>

                  {/* Content */}
                  <div className="p-6">
                    <div className="mb-3">
                      <span className="text-primary text-xs font-bold">
                        {course.category}
                      </span>
                    </div>

                    <h3 className="text-xl font-bold text-white mb-2 group-hover:text-primary transition-colors">
                      {course.title}
                    </h3>

                    <p className="text-white/70 text-sm mb-4 line-clamp-2">
                      {course.description}
                    </p>

                    <div className="flex items-center gap-2 text-white/60 text-sm mb-4">
                      <span>👤 {course.instructor}</span>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4 text-white/60 text-sm">
                        <span>⏱️ {course.duration}</span>
                        <span>📚 {course.lessons} lessons</span>
                      </div>
                    </div>

                    {isStarted && (
                      <div className="mt-4 pt-4 border-t border-white/10">
                        <div className="flex items-center justify-between text-sm">
                          <span className="text-white/60">{progress}% complete</span>
                          <button className="text-primary font-bold hover:underline">
                            Continue →
                          </button>
                        </div>
                      </div>
                    )}

                    {!isStarted && (
                      <button className="w-full mt-4 px-4 py-3 bg-gradient-to-r from-primary to-purple-500 text-white rounded-xl font-bold hover:shadow-lg transition-shadow">
                        Start Course
                      </button>
                    )}
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>

        {/* Empty State */}
        {filteredCourses.length === 0 && (
          <div className="text-center py-20">
            <div className="text-6xl mb-4">📚</div>
            <h3 className="text-2xl font-bold text-white mb-2">
              No courses in this category yet
            </h3>
            <p className="text-white/60 mb-6">
              Check back soon for new courses!
            </p>
            <button
              onClick={() => setSelectedCategory('All')}
              className="px-6 py-3 bg-primary text-white rounded-full font-bold"
            >
              View All Courses
            </button>
          </div>
        )}

        {/* Info Section */}
        <div className="mt-16 mb-8">
          <div className="glass-strong rounded-2xl p-8 text-center">
            <h3 className="text-2xl font-bold text-white mb-3">
              Why Learn with Homey?
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
              <div>
                <div className="text-4xl mb-3">🎓</div>
                <h4 className="text-lg font-bold text-white mb-2">Expert Instructors</h4>
                <p className="text-white/70 text-sm">
                  Learn from real estate professionals with years of experience
                </p>
              </div>
              <div>
                <div className="text-4xl mb-3">⚡</div>
                <h4 className="text-lg font-bold text-white mb-2">At Your Pace</h4>
                <p className="text-white/70 text-sm">
                  Watch lessons anytime, anywhere, and review as needed
                </p>
              </div>
              <div>
                <div className="text-4xl mb-3">🎯</div>
                <h4 className="text-lg font-bold text-white mb-2">Actionable Insights</h4>
                <p className="text-white/70 text-sm">
                  Apply what you learn immediately to your home search
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
