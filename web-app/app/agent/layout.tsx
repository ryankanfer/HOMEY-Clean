'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Users,
  MessageSquare,
  FileText,
  Home as HomeIcon,
  Calendar,
  TrendingUp,
  Settings,
  Menu,
  X
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export default function AgentLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Hide layout on registration page
  const isRegisterPage = pathname === '/agent/register';

  const navigation = [
    { name: 'Dashboard', href: '/agent', icon: LayoutDashboard },
    { name: 'Clients', href: '/agent/clients', icon: Users },
    { name: 'Messages', href: '/agent/messages', icon: MessageSquare },
    { name: 'Listings', href: '/agent/listings', icon: HomeIcon },
    { name: 'Documents', href: '/agent/documents', icon: FileText },
    { name: 'Showings', href: '/agent/showings', icon: Calendar },
    { name: 'Analytics', href: '/agent/analytics', icon: TrendingUp },
  ];

  // If on register page, just render children without layout
  if (isRegisterPage) {
    return <>{children}</>;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-purple-950 to-slate-950">
      {/* Mobile Header */}
      <div className="lg:hidden fixed top-0 left-0 right-0 z-50 bg-black/40 backdrop-blur-xl border-b border-white/10">
        <div className="flex items-center justify-between p-4">
          <Link href="/agent" className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
              <span className="text-white font-bold text-sm">H</span>
            </div>
            <span className="text-white font-semibold">HOMEY Agent</span>
          </Link>

          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="w-10 h-10 rounded-lg glass-strong flex items-center justify-center"
          >
            {mobileMenuOpen ? (
              <X className="w-5 h-5 text-white" />
            ) : (
              <Menu className="w-5 h-5 text-white" />
            )}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="lg:hidden fixed inset-y-0 right-0 z-40 w-64 bg-black/95 backdrop-blur-xl border-l border-white/10 pt-20"
          >
            <nav className="p-4 space-y-2">
              {navigation.map((item) => {
                const isActive = pathname === item.href;
                const Icon = item.icon;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    onClick={() => setMobileMenuOpen(false)}
                    className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
                      isActive
                        ? 'bg-gradient-to-r from-purple-500/20 to-pink-500/20 text-white border border-white/20'
                        : 'text-white/60 hover:text-white hover:bg-white/5'
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                    <span className="font-medium">{item.name}</span>
                  </Link>
                );
              })}

              <div className="pt-4 border-t border-white/10">
                <Link
                  href="/settings"
                  onClick={() => setMobileMenuOpen(false)}
                  className="flex items-center gap-3 px-4 py-3 rounded-xl text-white/60 hover:text-white hover:bg-white/5 transition-all"
                >
                  <Settings className="w-5 h-5" />
                  <span className="font-medium">Settings</span>
                </Link>
              </div>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Desktop Sidebar */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:left-0 lg:z-40 lg:w-72 lg:flex lg:flex-col">
        <div className="flex flex-col flex-1 glass-strong border-r border-white/10">
          {/* Logo */}
          <div className="p-6 border-b border-white/10">
            <Link href="/agent" className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                <span className="text-white font-bold">H</span>
              </div>
              <div>
                <div className="text-white font-bold text-lg">HOMEY Agent</div>
                <div className="text-white/60 text-xs">Professional Portal</div>
              </div>
            </Link>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
            {navigation.map((item) => {
              const isActive = pathname === item.href;
              const Icon = item.icon;
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
                    isActive
                      ? 'bg-gradient-to-r from-purple-500/20 to-pink-500/20 text-white border border-white/20 shadow-lg'
                      : 'text-white/60 hover:text-white hover:bg-white/5'
                  }`}
                >
                  <Icon className="w-5 h-5" />
                  <span className="font-medium">{item.name}</span>
                  {isActive && (
                    <motion.div
                      layoutId="activeTab"
                      className="ml-auto w-2 h-2 rounded-full bg-gradient-to-r from-purple-400 to-pink-400"
                    />
                  )}
                </Link>
              );
            })}
          </nav>

          {/* Bottom Actions */}
          <div className="p-4 border-t border-white/10 space-y-2">
            <Link
              href="/settings"
              className="flex items-center gap-3 px-4 py-3 rounded-xl text-white/60 hover:text-white hover:bg-white/5 transition-all"
            >
              <Settings className="w-5 h-5" />
              <span className="font-medium">Settings</span>
            </Link>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="lg:pl-72">
        <main className="min-h-screen pt-20 lg:pt-0">
          {children}
        </main>
      </div>
    </div>
  );
}
