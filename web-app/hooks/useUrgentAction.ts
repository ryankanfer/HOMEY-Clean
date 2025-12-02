import { useState, useEffect } from 'react';
import { auth, db } from '@/lib/supabase';

// 🧪 TEST MODE: Set to true to see urgent state immediately
const TEST_URGENT_MODE = false;

// 🎯 Choose which urgent action to demo (only used if TEST_URGENT_MODE is true)
const TEST_ACTION_TYPE: 'disclosure' | 'lease' | 'tour' | 'application' = 'disclosure';

export interface UrgentAction {
  id: string;
  type: 'sign_disclosure' | 'sign_lease' | 'submit_application' | 'confirm_tour' | 'payment_due' | 'deadline_approaching';
  title: string;
  description: string;
  action: string;
  href: string;
  deadline?: Date;
  priority: 'critical' | 'urgent' | 'high';
}

export function useUrgentAction() {
  const [urgentAction, setUrgentAction] = useState<UrgentAction | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkForUrgentActions();
    // Check every 30 seconds for new urgent actions
    const interval = setInterval(checkForUrgentActions, 30000);
    return () => clearInterval(interval);
  }, []);

  const checkForUrgentActions = async () => {
    // 🧪 TEST MODE: Return demo urgent action immediately
    if (TEST_URGENT_MODE) {
      const testActions = {
        disclosure: {
          id: 'test-disclosure-1',
          type: 'sign_disclosure' as const,
          title: 'Sign Disclosure',
          description: 'Required disclosure needs your signature',
          action: 'Sign Now',
          href: '/vault?action=sign',
          priority: 'critical' as const,
          deadline: new Date(Date.now() + 24 * 60 * 60 * 1000),
        },
        lease: {
          id: 'test-lease-1',
          type: 'sign_lease' as const,
          title: 'Sign Lease',
          description: 'Your lease is ready for signature',
          action: 'Sign Lease',
          href: '/vault?action=sign-lease',
          priority: 'critical' as const,
        },
        tour: {
          id: 'test-tour-1',
          type: 'confirm_tour' as const,
          title: 'Confirm Tour',
          description: 'Confirm your tour for today at 2pm',
          action: 'Confirm',
          href: '/calendar',
          priority: 'urgent' as const,
        },
        application: {
          id: 'test-app-1',
          type: 'submit_application' as const,
          title: 'Complete Application',
          description: 'Finish your rental application for 245 E 25th St',
          action: 'Complete Now',
          href: '/vault?action=application',
          priority: 'high' as const,
        },
      };

      setUrgentAction(testActions[TEST_ACTION_TYPE]);
      setLoading(false);
      return;
    }

    // PRODUCTION MODE: Check real database
    try {
      const { data: { user } } = await auth.getUser();
      if (!user) {
        setLoading(false);
        return;
      }

      // Get the highest priority urgent action from database
      const { data: dbAction, error } = await db.getTopUrgentAction(user.id);

      if (error) {
        console.error('Failed to fetch urgent action:', error);
        setUrgentAction(null);
        setLoading(false);
        return;
      }

      if (dbAction) {
        // Map database action to UrgentAction interface
        setUrgentAction({
          id: dbAction.id,
          type: dbAction.action_type,
          title: dbAction.title,
          description: dbAction.description,
          action: dbAction.action_text,
          href: dbAction.href,
          deadline: dbAction.deadline ? new Date(dbAction.deadline) : undefined,
          priority: dbAction.priority,
        });
      } else {
        setUrgentAction(null);
      }

      setLoading(false);
    } catch (error) {
      console.error('Failed to check urgent actions:', error);
      setLoading(false);
    }
  };

  const dismissUrgentAction = async () => {
    if (!urgentAction) return;

    // Optimistically update UI
    const actionToDismiss = urgentAction;
    setUrgentAction(null);

    try {
      const { data: { user } } = await auth.getUser();
      if (!user) return;

      // Persist dismissal to database
      const { error } = await db.dismissUrgentAction(actionToDismiss.id, user.id);

      if (error) {
        console.error('Failed to dismiss urgent action:', error);
        // Restore the action if dismissal failed
        setUrgentAction(actionToDismiss);
      }
    } catch (error) {
      console.error('Failed to dismiss urgent action:', error);
      // Restore the action if dismissal failed
      setUrgentAction(actionToDismiss);
    }
  };

  const completeUrgentAction = async () => {
    if (!urgentAction) return;

    // Optimistically update UI
    const actionToComplete = urgentAction;
    setUrgentAction(null);

    try {
      const { data: { user } } = await auth.getUser();
      if (!user) return;

      // Persist completion to database
      const { error } = await db.completeUrgentAction(actionToComplete.id, user.id);

      if (error) {
        console.error('Failed to complete urgent action:', error);
        // Restore the action if completion failed
        setUrgentAction(actionToComplete);
      }
    } catch (error) {
      console.error('Failed to complete urgent action:', error);
      // Restore the action if completion failed
      setUrgentAction(actionToComplete);
    }
  };

  return {
    urgentAction,
    loading,
    dismissUrgentAction,
    completeUrgentAction,
    refreshUrgentActions: checkForUrgentActions,
  };
}
