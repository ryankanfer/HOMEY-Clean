'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import CinematicBackground from '@/components/CinematicBackground';

interface Lesson {
  id: string;
  title: string;
  duration: string;
  description: string;
  keyTakeaways: string[];
  videoPlaceholder: string;
}

interface CourseData {
  id: string;
  title: string;
  description: string;
  instructor: string;
  instructorBio: string;
  category: string;
  difficulty: string;
  lessons: Lesson[];
}

// Mock course data - in production, this would come from a database
const coursesData: { [key: string]: CourseData } = {
  'first-time-buyer-101': {
    id: 'first-time-buyer-101',
    title: 'First-Time Home Buyer Essentials',
    description: 'Learn everything you need to know about buying your first home.',
    instructor: 'Sarah Chen',
    instructorBio: '15+ years in real estate, helped 500+ first-time buyers',
    category: 'First-Time Buyer',
    difficulty: 'Beginner',
    lessons: [
      {
        id: 'lesson-1',
        title: 'Introduction: Your Home Buying Journey',
        duration: '8 min',
        description: 'Overview of the home buying process and what to expect',
        keyTakeaways: [
          'Understand the complete timeline of buying a home',
          'Learn about different types of home ownership',
          'Set realistic expectations for your search',
        ],
        videoPlaceholder: '🎬',
      },
      {
        id: 'lesson-2',
        title: 'Setting Your Budget',
        duration: '15 min',
        description: 'How to determine what you can afford and plan your finances',
        keyTakeaways: [
          'Calculate your maximum home price',
          'Understand the 28/36 rule',
          'Plan for down payment and closing costs',
        ],
        videoPlaceholder: '💵',
      },
      {
        id: 'lesson-3',
        title: 'Getting Pre-Approved',
        duration: '12 min',
        description: 'The pre-approval process and why it matters',
        keyTakeaways: [
          'Difference between pre-qual and pre-approval',
          'Documents you\'ll need',
          'How to shop for lenders',
        ],
        videoPlaceholder: '✅',
      },
      {
        id: 'lesson-4',
        title: 'Finding Your Perfect Home',
        duration: '18 min',
        description: 'Search strategies and making the most of viewings',
        keyTakeaways: [
          'How to prioritize your must-haves',
          'Red flags to watch for',
          'Questions to ask at viewings',
        ],
        videoPlaceholder: '🏠',
      },
      {
        id: 'lesson-5',
        title: 'Making an Offer',
        duration: '14 min',
        description: 'Negotiation tactics and offer strategy',
        keyTakeaways: [
          'How to determine your offer price',
          'Contingencies that protect you',
          'Escalation clauses explained',
        ],
        videoPlaceholder: '📝',
      },
    ],
  },
  'neighborhood-research': {
    id: 'neighborhood-research',
    title: 'Mastering Neighborhood Research',
    description: 'Learn how to evaluate neighborhoods and find your perfect community.',
    instructor: 'Marcus Williams',
    instructorBio: 'Urban planning expert with 20 years of experience',
    category: 'Neighborhoods',
    difficulty: 'Beginner',
    lessons: [
      {
        id: 'lesson-1',
        title: 'Why Neighborhoods Matter',
        duration: '10 min',
        description: 'Understanding the impact of location on your lifestyle and investment',
        keyTakeaways: [
          'How neighborhoods affect property values',
          'The importance of community fit',
          'Long-term neighborhood trends',
        ],
        videoPlaceholder: '📍',
      },
      {
        id: 'lesson-2',
        title: 'Researching Crime & Safety',
        duration: '12 min',
        description: 'How to assess neighborhood safety and access crime data',
        keyTakeaways: [
          'Where to find reliable crime statistics',
          'Understanding crime rate trends',
          'Safety factors beyond crime data',
        ],
        videoPlaceholder: '🛡️',
      },
      {
        id: 'lesson-3',
        title: 'Schools & Education',
        duration: '14 min',
        description: 'Evaluating school districts and educational opportunities',
        keyTakeaways: [
          'How to research school ratings',
          'Beyond test scores: what else matters',
          'Impact on property values',
        ],
        videoPlaceholder: '🎓',
      },
    ],
  },
};

export default function CoursePlayerPage() {
  const router = useRouter();
  const params = useParams();
  const courseId = params.id as string;

  const [userId, setUserId] = useState<string | null>(null);
  const [course, setCourse] = useState<CourseData | null>(null);
  const [currentLessonIndex, setCurrentLessonIndex] = useState(0);
  const [completedLessons, setCompletedLessons] = useState<Set<string>>(new Set());
  const [showNotes, setShowNotes] = useState(false);

  useEffect(() => {
    loadCourse();
    loadUser();
  }, [courseId]);

  const loadCourse = () => {
    const courseData = coursesData[courseId];
    if (courseData) {
      setCourse(courseData);
      analytics.startCourse(courseId);
    }
  };

  const loadUser = async () => {
    const { data: { user } } = await auth.getUser();
    if (user) {
      setUserId(user.id);
      // TODO: Load user's lesson progress from database
    }
  };

  const markLessonComplete = async () => {
    if (!course) return;

    const currentLesson = course.lessons[currentLessonIndex];
    const newCompleted = new Set(completedLessons);
    newCompleted.add(currentLesson.id);
    setCompletedLessons(newCompleted);

    analytics.completeLesson(courseId, currentLesson.id);

    // TODO: Save progress to database
    if (userId) {
      // await db.updateCourseProgress(userId, courseId, currentLesson.id);
    }

    // Auto-advance to next lesson
    if (currentLessonIndex < course.lessons.length - 1) {
      setTimeout(() => {
        setCurrentLessonIndex(currentLessonIndex + 1);
      }, 1000);
    }
  };

  if (!course) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="text-center text-white">
          <h1 className="text-2xl font-bold mb-4">Course Not Found</h1>
          <button
            onClick={() => router.push('/learn')}
            className="px-6 py-3 bg-primary text-white rounded-full font-bold"
          >
            Back to Courses
          </button>
        </div>
      </main>
    );
  }

  const currentLesson = course.lessons[currentLessonIndex];
  const progressPercentage = Math.round((completedLessons.size / course.lessons.length) * 100);
  const isCurrentLessonComplete = completedLessons.has(currentLesson.id);

  return (
    <main className="relative min-h-screen bg-black">
      {/* Video Player Area */}
      <div className="relative w-full aspect-video bg-gradient-to-br from-primary/20 to-purple-600/20 flex items-center justify-center">
        <div className="text-center">
          <div className="text-9xl mb-4">{currentLesson.videoPlaceholder}</div>
          <p className="text-white/60 text-sm">Video player placeholder</p>
          <p className="text-white text-lg mt-2">{currentLesson.duration}</p>
        </div>

        {/* Player Controls Overlay */}
        <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-black/80 to-transparent">
          <div className="flex items-center gap-4">
            <button
              onClick={() => {
                if (currentLessonIndex > 0) {
                  setCurrentLessonIndex(currentLessonIndex - 1);
                }
              }}
              disabled={currentLessonIndex === 0}
              className="w-12 h-12 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              ⏮️
            </button>

            <div className="flex-1">
              <div className="h-1 bg-white/20 rounded-full overflow-hidden">
                <div
                  className="h-full bg-primary transition-all"
                  style={{ width: '35%' }} // Placeholder progress
                />
              </div>
            </div>

            <button
              onClick={() => {
                if (currentLessonIndex < course.lessons.length - 1) {
                  setCurrentLessonIndex(currentLessonIndex + 1);
                }
              }}
              disabled={currentLessonIndex === course.lessons.length - 1}
              className="w-12 h-12 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              ⏭️
            </button>
          </div>
        </div>

        {/* Back Button */}
        <button
          onClick={() => router.push('/learn')}
          className="absolute top-6 left-6 w-12 h-12 rounded-full bg-black/40 backdrop-blur-sm flex items-center justify-center text-white text-xl hover:bg-black/60 transition-colors"
        >
          ←
        </button>
      </div>

      {/* Content Area */}
      <div className="max-w-7xl mx-auto px-5 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Lesson Info */}
            <div className="mb-6">
              <div className="flex items-center gap-3 mb-3">
                <span className="text-primary text-sm font-bold">{course.category}</span>
                <span className="text-white/40">•</span>
                <span className="text-white/60 text-sm">Lesson {currentLessonIndex + 1} of {course.lessons.length}</span>
              </div>

              <h1 className="text-3xl font-bold text-white mb-3">
                {currentLesson.title}
              </h1>

              <p className="text-white/80 text-lg mb-4">
                {currentLesson.description}
              </p>

              <div className="flex items-center gap-3">
                <img
                  src={`https://ui-avatars.com/api/?name=${encodeURIComponent(course.instructor)}&background=6366f1&color=fff&size=48`}
                  alt={course.instructor}
                  className="w-12 h-12 rounded-full"
                />
                <div>
                  <p className="text-white font-semibold">{course.instructor}</p>
                  <p className="text-white/60 text-sm">{course.instructorBio}</p>
                </div>
              </div>
            </div>

            {/* Key Takeaways */}
            <div className="glass-strong rounded-2xl p-6 mb-6">
              <h3 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
                <span>💡</span>
                Key Takeaways
              </h3>
              <div className="space-y-3">
                {currentLesson.keyTakeaways.map((takeaway, index) => (
                  <motion.div
                    key={index}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1 }}
                    className="flex items-start gap-3"
                  >
                    <div className="w-6 h-6 rounded-full bg-primary flex items-center justify-center flex-shrink-0 mt-0.5">
                      <span className="text-white text-xs">✓</span>
                    </div>
                    <p className="text-white/90 leading-relaxed">{takeaway}</p>
                  </motion.div>
                ))}
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-4">
              <button
                onClick={markLessonComplete}
                disabled={isCurrentLessonComplete}
                className={`flex-1 px-6 py-4 rounded-xl font-bold transition-all ${
                  isCurrentLessonComplete
                    ? 'bg-green-500 text-white cursor-default'
                    : 'bg-primary text-white hover:bg-primary/90'
                }`}
              >
                {isCurrentLessonComplete ? '✓ Completed' : 'Mark as Complete'}
              </button>

              {currentLessonIndex < course.lessons.length - 1 && (
                <button
                  onClick={() => setCurrentLessonIndex(currentLessonIndex + 1)}
                  className="px-6 py-4 bg-white/10 text-white rounded-xl font-bold hover:bg-white/20 transition-colors"
                >
                  Next Lesson →
                </button>
              )}
            </div>
          </div>

          {/* Sidebar */}
          <div className="lg:col-span-1">
            {/* Course Progress */}
            <div className="glass-strong rounded-2xl p-6 mb-6">
              <h3 className="text-lg font-bold text-white mb-3">Course Progress</h3>
              <div className="mb-3">
                <div className="flex justify-between text-sm mb-2">
                  <span className="text-white/60">Overall</span>
                  <span className="text-white font-bold">{progressPercentage}%</span>
                </div>
                <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-primary to-purple-500 transition-all"
                    style={{ width: `${progressPercentage}%` }}
                  />
                </div>
              </div>
              <p className="text-white/60 text-sm">
                {completedLessons.size} of {course.lessons.length} lessons completed
              </p>
            </div>

            {/* Lesson List */}
            <div className="glass-strong rounded-2xl p-6">
              <h3 className="text-lg font-bold text-white mb-4">Lessons</h3>
              <div className="space-y-2">
                {course.lessons.map((lesson, index) => {
                  const isCompleted = completedLessons.has(lesson.id);
                  const isCurrent = index === currentLessonIndex;

                  return (
                    <button
                      key={lesson.id}
                      onClick={() => setCurrentLessonIndex(index)}
                      className={`w-full text-left p-3 rounded-xl transition-all ${
                        isCurrent
                          ? 'bg-primary text-white'
                          : isCompleted
                          ? 'bg-green-500/20 text-white hover:bg-green-500/30'
                          : 'bg-white/5 text-white/80 hover:bg-white/10'
                      }`}
                    >
                      <div className="flex items-start gap-3">
                        <div className="flex-shrink-0 w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-xs font-bold">
                          {isCompleted ? '✓' : index + 1}
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="font-semibold text-sm mb-1 truncate">
                            {lesson.title}
                          </p>
                          <p className="text-xs opacity-75">{lesson.duration}</p>
                        </div>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
