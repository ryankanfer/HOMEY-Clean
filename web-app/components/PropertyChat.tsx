'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import type { Listing } from '@/lib/types';
import BottomSheet from './BottomSheet';

interface PropertyChatProps {
  isOpen: boolean;
  onClose: () => void;
  property: Listing;
}

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

export default function PropertyChat({
  isOpen,
  onClose,
  property,
}: PropertyChatProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Suggested questions
  const suggestedQuestions = [
    "What's included in the rent?",
    "Is parking available?",
    "Are pets allowed?",
    "What's the lease term?",
    "Tell me about the neighborhood",
    "What amenities are nearby?",
    "How's public transportation?",
    "When is it available?",
  ];

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Initial welcome message
  useEffect(() => {
    if (isOpen && messages.length === 0) {
      const welcomeMessage: Message = {
        id: '1',
        role: 'assistant',
        content: `Hi! I can answer questions about ${property.address}. What would you like to know?`,
        timestamp: new Date(),
      };
      setMessages([welcomeMessage]);
    }
  }, [isOpen, property.address]);

  const generateResponse = async (question: string): Promise<string> => {
    // In production, this would call an AI API (OpenAI, Anthropic, etc.)
    // For now, generate contextual responses based on property data

    const lowerQuestion = question.toLowerCase();

    if (lowerQuestion.includes('rent') || lowerQuestion.includes('included')) {
      return `The monthly rent for ${property.address} is $${property.price.toLocaleString()}. Typically, water and trash are included, while electricity and internet are separate. The property also includes access to building amenities like the gym and lounge.`;
    }

    if (lowerQuestion.includes('parking')) {
      return `This property includes one assigned parking spot in the underground garage. Guest parking is available on a first-come, first-served basis. There's also excellent street parking in the neighborhood.`;
    }

    if (lowerQuestion.includes('pet')) {
      return `Yes, this property is pet-friendly! Dogs and cats are welcome with a $300 one-time pet deposit. There's a 2-pet maximum, and breed restrictions may apply. The building also has a dog park on the rooftop.`;
    }

    if (lowerQuestion.includes('lease')) {
      return `The standard lease term is 12 months, with flexible start dates. Month-to-month leases may be available after the initial term. The landlord typically requires first month's rent, last month's rent, and one month security deposit upfront.`;
    }

    if (lowerQuestion.includes('neighborhood') || lowerQuestion.includes('area')) {
      return `${property.neighborhood} is a vibrant neighborhood known for its dining scene, walkability, and community feel. You'll find plenty of cafes, restaurants, and shops within a 5-minute walk. The area is popular with young professionals and has great nightlife on weekends.`;
    }

    if (lowerQuestion.includes('amenities') || lowerQuestion.includes('nearby')) {
      return `The area has excellent amenities! Within a 5-minute walk, you'll find: Whole Foods (0.3 mi), multiple cafes and restaurants, a 24-hour gym, a public library, and several parks. There's also a farmers market every Saturday morning.`;
    }

    if (lowerQuestion.includes('transport') || lowerQuestion.includes('transit') || lowerQuestion.includes('commute')) {
      return `Public transportation is excellent! The nearest subway station is just 0.2 miles away (3-minute walk), with multiple lines providing access throughout the city. There are also several bus routes nearby. Most residents can commute to downtown in under 30 minutes.`;
    }

    if (lowerQuestion.includes('available') || lowerQuestion.includes('move')) {
      return `This property is available for immediate move-in! The current availability allows for flexible move-in dates within the next 30 days. Early move-in may be possible with advance notice.`;
    }

    if (lowerQuestion.includes('utilities') || lowerQuestion.includes('bills')) {
      return `Water, trash, and building maintenance are included in rent. Tenants are responsible for electricity (typically $50-80/month), gas/heat (seasonal, $30-60/month), and internet/cable (varies by provider). Total estimated utilities: $100-150/month.`;
    }

    if (lowerQuestion.includes('square') || lowerQuestion.includes('size') || lowerQuestion.includes('sqft')) {
      return `This ${property.bedrooms}-bedroom, ${property.bathrooms}-bathroom unit is ${property.square_footage?.toLocaleString() || 'approximately 900'} square feet. The layout is open-concept with good natural light. Bedrooms are generously sized with ample closet space.`;
    }

    // Default response
    return `That's a great question about ${property.address}! For specific details about this property, I recommend scheduling a tour or contacting the listing agent directly. They can provide the most accurate and up-to-date information. Is there anything else I can help you with?`;
  };

  const handleSendMessage = async (content: string) => {
    if (!content.trim()) return;

    // Add user message
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: content.trim(),
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsTyping(true);

    // Simulate AI thinking time
    await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 1000));

    // Generate and add assistant response
    const response = await generateResponse(content);
    const assistantMessage: Message = {
      id: (Date.now() + 1).toString(),
      role: 'assistant',
      content: response,
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, assistantMessage]);
    setIsTyping(false);
  };

  const handleSuggestedQuestion = (question: string) => {
    handleSendMessage(question);
  };

  return (
    <BottomSheet isOpen={isOpen} onClose={onClose} title="Ask About This Property" height="full">
      <div className="flex flex-col h-full">
        {/* Property Info Header */}
        <div className="px-6 pt-4 pb-2 border-b border-white/10">
          <div className="flex gap-3">
            <img
              src={property.image_urls?.[0] || '/placeholder-property.jpg'}
              alt={property.address}
              className="w-16 h-16 rounded-lg object-cover"
            />
            <div className="flex-1">
              <p className="text-white font-semibold text-sm">{property.address}</p>
              <p className="text-white/60 text-xs">{property.neighborhood}</p>
              <p className="text-primary font-bold text-sm mt-1">
                ${property.price.toLocaleString()}
                {property.listing_type === 'rental' && '/mo'}
              </p>
            </div>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto px-6 py-4 space-y-4">
          <AnimatePresence initial={false}>
            {messages.map((message) => (
              <motion.div
                key={message.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0 }}
                className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
              >
                <div
                  className={`max-w-[80%] px-4 py-3 rounded-2xl ${
                    message.role === 'user'
                      ? 'bg-primary text-white rounded-br-sm'
                      : 'bg-white/10 text-white rounded-bl-sm'
                  }`}
                >
                  {message.role === 'assistant' && (
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-lg">🤖</span>
                      <span className="text-xs text-white/60 font-medium">HOMEY Assistant</span>
                    </div>
                  )}
                  <p className="text-sm leading-relaxed whitespace-pre-wrap">{message.content}</p>
                  <p className="text-xs text-white/40 mt-1">
                    {message.timestamp.toLocaleTimeString('en-US', {
                      hour: 'numeric',
                      minute: '2-digit',
                    })}
                  </p>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>

          {/* Typing Indicator */}
          {isTyping && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="flex justify-start"
            >
              <div className="bg-white/10 px-4 py-3 rounded-2xl rounded-bl-sm">
                <div className="flex items-center gap-2">
                  <span className="text-lg">🤖</span>
                  <div className="flex gap-1">
                    <motion.span
                      animate={{ opacity: [0.4, 1, 0.4] }}
                      transition={{ repeat: Infinity, duration: 1, delay: 0 }}
                      className="w-2 h-2 bg-white/60 rounded-full"
                    />
                    <motion.span
                      animate={{ opacity: [0.4, 1, 0.4] }}
                      transition={{ repeat: Infinity, duration: 1, delay: 0.2 }}
                      className="w-2 h-2 bg-white/60 rounded-full"
                    />
                    <motion.span
                      animate={{ opacity: [0.4, 1, 0.4] }}
                      transition={{ repeat: Infinity, duration: 1, delay: 0.4 }}
                      className="w-2 h-2 bg-white/60 rounded-full"
                    />
                  </div>
                </div>
              </div>
            </motion.div>
          )}

          {/* Suggested Questions (show when no messages yet or few messages) */}
          {messages.length <= 2 && !isTyping && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="pt-2"
            >
              <p className="text-white/60 text-xs mb-3">Suggested questions:</p>
              <div className="flex flex-wrap gap-2">
                {suggestedQuestions.map((question, idx) => (
                  <motion.button
                    key={idx}
                    onClick={() => handleSuggestedQuestion(question)}
                    whileTap={{ scale: 0.95 }}
                    className="px-3 py-2 bg-white/10 hover:bg-white/20 rounded-full text-white/80 text-xs transition-colors"
                  >
                    {question}
                  </motion.button>
                ))}
              </div>
            </motion.div>
          )}

          <div ref={messagesEndRef} />
        </div>

        {/* Input Area */}
        <div className="px-6 py-4 border-t border-white/10">
          <div className="flex gap-2">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyPress={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  handleSendMessage(input);
                }
              }}
              placeholder="Ask a question about this property..."
              className="flex-1 px-4 py-3 bg-white/5 border border-white/10 rounded-full text-white placeholder-white/40 focus:outline-none focus:border-primary/50"
              disabled={isTyping}
            />
            <button
              onClick={() => handleSendMessage(input)}
              disabled={!input.trim() || isTyping}
              className={`w-12 h-12 rounded-full flex items-center justify-center transition-all ${
                input.trim() && !isTyping
                  ? 'bg-primary text-white hover:bg-primary/90'
                  : 'bg-white/10 text-white/40 cursor-not-allowed'
              }`}
            >
              ↑
            </button>
          </div>
          <p className="text-white/40 text-xs mt-2 text-center">
            AI-powered answers • Press Enter to send
          </p>
        </div>
      </div>
    </BottomSheet>
  );
}
