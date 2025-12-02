'use client';

import { useState, useEffect, ReactNode } from 'react';
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  TouchSensor,
  useSensor,
  useSensors,
  DragEndEvent,
  DragStartEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { motion } from 'framer-motion';
import { GripVertical } from 'lucide-react';

interface Widget {
  id: string;
  component: ReactNode;
}

interface SortableWidgetProps {
  id: string;
  children: ReactNode;
  isLongPress: boolean;
}

function SortableWidget({ id, children, isLongPress }: SortableWidgetProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`relative group ${isLongPress ? 'select-none cursor-grab active:cursor-grabbing' : ''}`}
      {...(isLongPress ? attributes : {})}
      {...(isLongPress ? listeners : {})}
    >
      {/* Drag Handle - Only visible in edit mode */}
      {isLongPress && (
        <motion.div
          className="absolute -left-12 top-1/2 -translate-y-1/2 z-50 pointer-events-none"
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: 20 }}
        >
          <div className="p-2 bg-white/10 backdrop-blur-sm rounded-lg border border-white/20 shadow-lg">
            <GripVertical className="w-6 h-6 text-white" />
          </div>
        </motion.div>
      )}

      {/* Widget Content */}
      <div
        className={`${isDragging ? 'opacity-50' : ''} ${isLongPress ? 'ring-2 ring-purple-500/50 rounded-3xl' : ''}`}
        style={isLongPress ? { userSelect: 'none', WebkitUserSelect: 'none', WebkitTouchCallout: 'none' } : {}}
      >
        {children}
      </div>
    </div>
  );
}

interface DraggableWidgetsProps {
  widgets: Widget[];
  onOrderChange?: (newOrder: Widget[]) => void;
}

export default function DraggableWidgets({ widgets: initialWidgets, onOrderChange }: DraggableWidgetsProps) {
  const [widgets, setWidgets] = useState(initialWidgets);
  const [isEditMode, setIsEditMode] = useState(false);
  const [longPressTimer, setLongPressTimer] = useState<NodeJS.Timeout | null>(null);
  const [activeId, setActiveId] = useState<string | null>(null);

  // Sensors for drag detection
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 5, // 5px movement before drag starts (reduced from 8)
      },
    }),
    useSensor(TouchSensor, {
      activationConstraint: {
        delay: 500, // 500ms long press (reduced from 800)
        tolerance: 5,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  useEffect(() => {
    setWidgets(initialWidgets);
  }, [initialWidgets]);

  // Save order to localStorage when it changes
  useEffect(() => {
    if (widgets.length > 0) {
      const order = widgets.map(w => w.id);
      localStorage.setItem('homey_widget_order', JSON.stringify(order));

      if (onOrderChange) {
        onOrderChange(widgets);
      }
    }
  }, [widgets, onOrderChange]);

  function handleDragStart(event: DragStartEvent) {
    setActiveId(event.active.id as string);
    setIsEditMode(true);
  }

  function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event;
    setActiveId(null);

    if (over && active.id !== over.id) {
      setWidgets((items) => {
        const oldIndex = items.findIndex((item) => item.id === active.id);
        const newIndex = items.findIndex((item) => item.id === over.id);

        return arrayMove(items, oldIndex, newIndex);
      });
    }

    // Exit edit mode after a short delay
    setTimeout(() => {
      setIsEditMode(false);
    }, 500);
  }

  // Handle long press to enter edit mode (for devices without touch)
  const handleMouseDown = () => {
    const timer = setTimeout(() => {
      setIsEditMode(true);
    }, 500); // Reduced from 800ms to 500ms
    setLongPressTimer(timer);
  };

  const handleMouseUp = () => {
    if (longPressTimer) {
      clearTimeout(longPressTimer);
      setLongPressTimer(null);
    }
  };

  return (
    <div
      onMouseDown={handleMouseDown}
      onMouseUp={handleMouseUp}
      onMouseLeave={handleMouseUp}
      onTouchStart={handleMouseDown}
      onTouchEnd={handleMouseUp}
    >
      {/* Edit Mode Indicator */}
      {isEditMode && (
        <motion.div
          className="px-5 mb-4"
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -10 }}
        >
          <div className="glass-strong rounded-2xl px-4 py-3 border border-purple-500/50">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-2 h-2 bg-purple-500 rounded-full animate-pulse" />
                <span className="text-white/90 text-sm font-medium">
                  Rearrange Mode Active
                </span>
              </div>
              <button
                onClick={() => setIsEditMode(false)}
                className="px-3 py-1 bg-purple-500/20 hover:bg-purple-500/30 text-purple-300 text-xs font-medium rounded-lg transition-colors"
              >
                Done
              </button>
            </div>
            <p className="text-white/50 text-xs mt-2">
              Drag any widget to reorder • Tap Done when finished
            </p>
          </div>
        </motion.div>
      )}

      <DndContext
        sensors={sensors}
        collisionDetection={closestCenter}
        onDragStart={handleDragStart}
        onDragEnd={handleDragEnd}
      >
        <SortableContext
          items={widgets.map(w => w.id)}
          strategy={verticalListSortingStrategy}
        >
          <div className="space-y-0">
            {widgets.map((widget) => (
              <SortableWidget key={widget.id} id={widget.id} isLongPress={isEditMode}>
                {widget.component}
              </SortableWidget>
            ))}
          </div>
        </SortableContext>
      </DndContext>
    </div>
  );
}
