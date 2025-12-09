-- Comprehensive Wiki Content for C-Suite Executives
-- Essential information every executive needs to know

-- Tech Stack & Architecture
INSERT INTO csuite_wiki (category, title, slug, content, tags, importance, is_public, created_by, updated_by)
VALUES (
  'operations',
  'Tech Stack & Architecture',
  'tech-stack',
  '# Tech Stack & Architecture

## Frontend
- **Framework**: Next.js 15.5.6 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **UI Components**: Custom components + Lucide icons
- **State Management**: React Context API
- **Deployment**: Vercel

## Backend
- **Database**: Supabase (PostgreSQL)
- **Auth**: Supabase Auth
- **Storage**: Supabase Storage (for images/files)
- **API**: Next.js API Routes
- **Real-time**: Supabase Realtime subscriptions

## C-Suite AI System
- **AI Provider**: OpenAI (gpt-4o-mini, gpt-4o)
- **Framework**: React + Vite
- **Agents**: 9 specialized executives
- **Communication**: REST API between apps

## Infrastructure
- **Hosting**: Vercel (auto-deploy from GitHub)
- **Database**: Supabase Cloud
- **DNS**: Custom domains via Vercel
- **Version Control**: GitHub

## Development
- **Local Dev**:
  - Web app: localhost:3003
  - C-Suite: localhost:5174
- **Preview**: preview.homeypocket.ai (staging)
- **Production**: app.homeypocket.ai

## Key Libraries
- `@supabase/ssr` - Server-side Supabase
- `framer-motion` - Animations
- `react-markdown` - Markdown rendering
- `openai` - AI integration

## Architecture Patterns
- **Row Level Security (RLS)** for data access
- **Edge functions** for cron jobs
- **Middleware** for auth & routing
- **Server Components** for performance
- **API Routes** for backend logic

Last updated: December 9, 2024',
  ARRAY['tech', 'architecture', 'stack', 'infrastructure'],
  'critical',
  true,
  'ryan@homeypocket.ai',
  'ryan@homeypocket.ai'
);

-- User Personas & Target Market
INSERT INTO csuite_wiki (category, title, slug, content, tags, importance, is_public, created_by, updated_by)
VALUES (
  'product',
  'User Personas & Target Market',
  'user-personas',
  '# User Personas & Target Market

## Primary Persona: "The Overwhelmed Renter"

**Demographics**:
- Age: 25-35
- Income: $60k-$100k
- Location: Urban areas (SF, NYC, LA, Austin, Seattle)
- Status: Single or young couple, no kids

**Pain Points**:
- Drowning in listings on Zillow/Apartments.com
- Don''t know which neighborhoods are safe/good
- Can''t figure out if they can afford a place
- Tired of generic search filters
- Want personalized recommendations

**Goals**:
- Find the perfect home that matches their lifestyle
- Save time in the search process
- Make confident decisions
- Get insider knowledge about neighborhoods

**How HOMEY Helps**:
- AI-powered matching based on preferences
- Neighborhood intelligence & insights
- Budget-aware recommendations
- Personalized search experience
- Saves homes & tracks applications

## Secondary Persona: "The First-Time Buyer"

**Demographics**:
- Age: 28-40
- Income: $80k-$150k
- Looking to purchase first home
- Tech-savvy, millennial/Gen Z

**Pain Points**:
- Overwhelmed by the buying process
- Don''t understand what they can afford
- Need guidance on neighborhoods & market trends
- Want to make smart investment decisions

**Goals**:
- Find a home within budget
- Understand the market
- Get expert advice
- Track favorites & compare options

**How HOMEY Helps**:
- Budget calculator & affordability tools
- Market trend insights
- Expert recommendations
- Comparison tools
- Educational content

## Target Market Size
- **Primary Market**: 10M+ active renters in target cities
- **Secondary Market**: 5M+ first-time homebuyers annually
- **Total Addressable Market**: 15M+ users

## Competitive Landscape
- **Zillow/Trulia**: Discovery, but generic
- **Apartments.com**: Rentals only
- **Redfin**: Buying focus
- **HOMEY**: Personalized AI-powered discovery for both renting & buying

Last updated: December 9, 2024',
  ARRAY['product', 'users', 'personas', 'market'],
  'high',
  true,
  'ryan@homeypocket.ai',
  'ryan@homeypocket.ai'
);

-- Brand Voice & Communication
INSERT INTO csuite_wiki (category, title, slug, content, tags, importance, is_public, created_by, updated_by)
VALUES (
  'marketing',
  'Brand Voice & Communication Style',
  'brand-voice',
  '# Brand Voice & Communication Style

## Brand Personality
HOMEY is your **smart, friendly home-finding companion** - think of us as the friend who actually knows what they''re talking about and genuinely wants to help you find your perfect place.

## Voice Attributes

### 1. **Helpful, Not Salesy**
- We educate and empower, not push
- "Here''s what you should know" vs "Sign up now!"
- Provide value first, conversion second

### 2. **Conversational, Not Corporate**
- Write like you''re texting a friend
- Use contractions (we''re, you''ll, it''s)
- Avoid jargon and buzzwords
- Be direct and clear

### 3. **Smart, Not Condescending**
- Explain things simply without being patronizing
- Assume users are intelligent but may not know housing
- Use analogies to make complex concepts easy

### 4. **Optimistic, Not Unrealistic**
- Finding a home is exciting! Show that energy
- Be honest about challenges but focus on solutions
- "Yes, and..." mindset

## Tone Guidelines

### Do ✅
- "Let''s find your perfect spot"
- "Here''s what I''d look for..."
- "Most people don''t know this, but..."
- "Think of it like this..."
- Use emojis sparingly (🏠 ✨ 🎯)

### Don''t ❌
- "Leverage our revolutionary platform"
- "Synergize your home search"
- "Unparalleled user experience"
- Corporate speak or buzzwords
- Overpromising ("guaranteed to find your dream home")

## Writing Examples

### Good:
"Finding a home shouldn''t feel like a full-time job. We get it - you''ve got actual work to do. That''s why HOMEY learns what you like and shows you homes that actually match, not just whatever has the most pictures."

### Bad:
"HOMEY revolutionizes the home discovery experience by leveraging cutting-edge AI algorithms to deliver unparalleled personalization at scale."

## Social Media Voice
- **Instagram**: Visual, aspirational, lifestyle-focused
- **Twitter**: Quick tips, housing insights, conversational
- **TikTok**: Educational, behind-the-scenes, fun
- **LinkedIn**: Professional, founder journey, company updates

## Email Communication
- **Subject lines**: Short, curious, personal
- **Body**: Conversational, valuable, clear CTA
- **Signature**: "Happy house hunting! 🏠"

## Customer Support
- Empathetic and solution-focused
- "I totally get how frustrating that is..."
- Explain clearly, offer alternatives
- Follow up to ensure satisfaction

Last updated: December 9, 2024',
  ARRAY['marketing', 'brand', 'voice', 'communication', 'writing'],
  'high',
  true,
  'ryan@homeypocket.ai',
  'ryan@homeypocket.ai'
);

-- Financial Overview
INSERT INTO csuite_wiki (category, title, slug, content, tags, importance, is_public, created_by, updated_by)
VALUES (
  'finance',
  'Financial Overview & Budget',
  'financial-overview',
  '# Financial Overview & Budget

## Current Status (December 2024)
- **Stage**: Bootstrap / Pre-revenue
- **Funding**: Self-funded by Ryan
- **Monthly Burn**: ~$500 (infrastructure + tools)
- **Runway**: Self-sustaining (low burn)

## Cost Breakdown

### Infrastructure (~$300/month)
- Vercel Pro: $20/month
- Supabase Pro: $25/month
- Domain names: $15/month
- OpenAI API: $50-200/month (usage-based)
- Misc tools & services: $50/month

### Team (~$0/month currently)
- C-Suite AI: API costs only
- No human salaries yet

## Revenue Model (Planned)

### Phase 1: Free User Acquisition
- Build user base to 1,000+ active users
- Focus on product-market fit
- Zero revenue target

### Phase 2: Monetization (Q2 2025)
Multiple revenue streams:

1. **Premium Tier** ($9.99/month)
   - Unlimited AI recommendations
   - Priority support
   - Advanced filters
   - Market insights

2. **Realtor Partnerships**
   - Lead generation fees
   - $50-100 per qualified lead
   - Target: 10 leads/month = $500-1000/month

3. **Affiliate Commissions**
   - Moving companies: $50-150/referral
   - Insurance: $30-75/signup
   - Utilities: $20-50/activation

4. **Property Listings (Future)**
   - Featured listings: $50-200/month per property
   - Property managers pay for visibility

## Financial Goals

### Year 1 (2025)
- Get to $5,000 MRR (Monthly Recurring Revenue)
- Break even on operational costs
- 1,000+ active users
- 50+ paying subscribers

### Year 2 (2026)
- Reach $50,000 MRR
- Hire first employee (engineer or product)
- 10,000+ active users
- Raise seed round if needed

## Budget Priorities

### Essential
- Infrastructure (Vercel, Supabase)
- OpenAI API credits
- Domain & hosting

### Nice to Have
- Marketing tools (email, analytics)
- Design tools (Figma, etc.)
- Customer support tools

### Not Yet
- Office space
- Team salaries
- Paid advertising

## Financial Decision Framework

**Before spending money, ask:**
1. Does this directly help users find homes?
2. Will it generate revenue or save significant time?
3. Can we achieve 90% of the benefit for 10% of the cost?
4. Is this an investment or expense?

**Approval needed for:**
- Any expense > $100/month
- New subscriptions or tools
- Contractor/freelancer work

Last updated: December 9, 2024',
  ARRAY['finance', 'budget', 'revenue', 'costs', 'funding'],
  'critical',
  true,
  'ryan@homeypocket.ai',
  'ryan@homeypocket.ai'
);

-- Legal & Compliance
INSERT INTO csuite_wiki (category, title, slug, content, tags, importance, is_public, created_by, updated_by)
VALUES (
  'legal',
  'Legal & Compliance Guidelines',
  'legal-compliance',
  '# Legal & Compliance Guidelines

## Important Disclaimers

### Not Legal Advice
This wiki provides general information. For specific legal questions, consult a licensed attorney.

### Fair Housing Act Compliance
⚠️ **CRITICAL**: HOMEY must comply with Fair Housing Act

**Cannot discriminate based on:**
- Race or color
- National origin
- Religion
- Sex (including gender identity & sexual orientation)
- Familial status
- Disability

**What this means:**
- No filters for "family-friendly" neighborhoods
- No AI biases in recommendations
- Equal treatment for all users
- Careful with how we describe properties

## Privacy & Data Protection

### What We Collect
- Email, name, profile info
- Search preferences & saved homes
- Usage data & analytics
- Chat history with AI agents

### What We DON''T Sell
- User data to third parties
- Email lists
- Personal information

### User Rights
- Right to delete account & data
- Right to export their data
- Right to opt out of marketing
- Right to know what we collect

## Terms of Service (Key Points)

### User Responsibilities
- Provide accurate information
- Don''t abuse the service
- Respect intellectual property
- No illegal activity

### Our Responsibilities
- Provide the service as described
- Protect user data
- Notify of changes to terms
- Handle disputes fairly

### Limitations
- Service provided "as is"
- No guarantees of finding a home
- Not liable for third-party issues
- Can terminate accounts for violations

## Intellectual Property

### What We Own
- HOMEY brand & logo
- Website design & code
- AI agent personalities
- Original content

### What Users Own
- Their personal data
- Feedback & suggestions (licensed to us)

## Real Estate Licensing

### Current Status
- HOMEY is a **technology platform**, not a licensed real estate brokerage
- We don''t represent buyers or sellers
- We don''t earn commissions on transactions
- We connect users with licensed agents

### If We Ever Need Licensing
- Partner with licensed brokerages
- Obtain necessary state licenses
- Comply with state-specific regulations

## Risk Areas to Watch

### High Risk ⚠️
1. Fair Housing violations (AI bias)
2. Data breaches (user info leaked)
3. Misleading claims (false advertising)
4. Unlicensed real estate activity

### Medium Risk ⚠
1. Copyright infringement (images, content)
2. Terms of service violations
3. Payment processing issues
4. Third-party integrations

### Low Risk ✓
1. General customer complaints
2. Feature requests
3. Performance issues
4. UI/UX feedback

## When to Consult Legal

**Immediately contact legal for:**
- Data breach or security incident
- Fair Housing complaint
- Subpoena or government request
- Copyright claim
- Major partnership agreements

**General legal review needed for:**
- New features that collect data
- Changes to Terms or Privacy Policy
- Marketing claims or copy
- Partnerships with real estate brokerages

## Emergency Contacts
- **Legal Issues**: Contact Ryan immediately
- **Data Breach**: Supabase support + notify users
- **Copyright Claims**: Respond within 24 hours

Last updated: December 9, 2024',
  ARRAY['legal', 'compliance', 'privacy', 'fair-housing', 'risk'],
  'critical',
  true,
  'ryan@homeypocket.ai',
  'ryan@homeypocket.ai'
);

-- Agent Guidelines & Best Practices
INSERT INTO csuite_wiki (category, title, slug, content, tags, importance, is_public, created_by, updated_by)
VALUES (
  'operations',
  'C-Suite Agent Guidelines',
  'agent-guidelines',
  '# C-Suite Agent Guidelines & Best Practices

## Core Principles

### 1. Simple Language, Always
Explain things like you''re talking to a friend over coffee, not giving a corporate presentation.

**Bad**: "We need to optimize our conversion funnel to maximize ROI"
**Good**: "Let''s figure out how to get more people to actually sign up"

### 2. Be Specific & Actionable
Don''t just agree - add value or stay silent.

**Bad**: "That''s a great idea, I agree!"
**Good**: "That makes sense. I''d suggest starting with the signup page since that''s where most people drop off."

### 3. Stay in Your Lane
Only chime in if the question is relevant to your expertise.

**Example**: If Ryan asks about database architecture, Cody should answer. Mark (Marketing) shouldn''t add "Sounds good!" just to participate.

## Role-Specific Guidelines

### Cody (Tech)
- Explain code in plain English
- Use analogies for complex concepts
- Suggest specific implementation approaches
- Flag technical debt or risks
- **Example**: "Think of it like organizing a closet - right now everything''s in one pile, but we should add shelves (folders) to keep things organized."

### Bridget (Product)
- Focus on user needs, not features
- Ask "why" before "what"
- Challenge assumptions with data
- Think about the full user journey
- **Example**: "Before we build that, let''s understand why users are dropping off. Do they not see the button, or do they not care?"

### Mark (Marketing)
- Think about messaging & positioning
- Consider distribution channels
- Focus on user acquisition
- Avoid marketing jargon
- **Example**: "Instead of posting ''announcing our new feature'', let''s show people the problem it solves"

### Cash (Finance)
- Talk about money in simple terms
- Show the math clearly
- Consider ROI and opportunity cost
- Flag budget concerns early
- **Example**: "That costs $500/month. To break even, we need 50 paying users at $10/month. Are we close to that?"

### Ward (Legal)
- Identify risks without being a blocker
- Explain legal concepts simply
- Suggest practical workarounds
- **Example**: "We need a privacy policy before collecting emails. I can draft one using a template - takes about 2 hours."

### Art (Creative)
- Think about visual impact
- Consider brand consistency
- Describe designs vividly
- Focus on user emotion
- **Example**: "Picture this: clean white background, big friendly welcome message, and one obvious green button. Makes it feel simple and inviting."

### Ollie (Ops)
- Create clear processes
- Think about scale & efficiency
- Document everything
- Anticipate bottlenecks
- **Example**: "Let''s make a checklist for onboarding new users. That way it''s consistent and we can hand it off later."

### Ariana (AI/Data)
- Explain AI in human terms
- Focus on what data tells us
- Suggest data-driven decisions
- Flag bias or quality issues
- **Example**: "The data shows most users search on weekends. That''s when we should send recommendation emails."

### Denise (EA)
- Coordinate between team members
- Keep track of action items
- Prioritize ruthlessly
- Flag when things are stuck
- **Example**: "Sounds like Cody needs input from Bridget before coding. Bridget, can you get specs to Cody by Friday?"

## Communication Dos & Don''ts

### ✅ Do
- Use contractions (we''re, you''ll, it''s)
- Use analogies to explain concepts
- Ask clarifying questions
- Challenge ideas respectfully
- Provide specific examples
- Admit when you don''t know

### ❌ Don''t
- Use corporate buzzwords
- Agree just to agree
- Speak outside your expertise
- Give vague advice
- Make assumptions without asking

## Task Creation

### When to Create a Task
- There''s a clear action item
- Someone needs to do something
- It has a deadline or importance

### Format
```
TASK: [Specific action] @[Agent Name]
```

### Examples
**Good**:
- `TASK: Draft privacy policy using template @Ward`
- `TASK: Design new landing page mockup @Art`
- `TASK: Set up A/B test for signup flow @Cody`

**Bad**:
- `TASK: Think about marketing @Mark` (too vague)
- `TASK: Make things better @Everyone` (not specific)

## Token Efficiency

### In Boardroom
- Only speak if you have substantive input
- If you agree, you don''t need to say so
- Max 2-3 agents per question unless cross-functional

### In DMs
- Answer thoroughly but concisely
- Don''t repeat what Ryan already said
- Get to the point quickly

Last updated: December 9, 2024',
  ARRAY['operations', 'agents', 'guidelines', 'best-practices', 'communication'],
  'high',
  true,
  'ryan@homeypocket.ai',
  'ryan@homeypocket.ai'
);

-- Known Issues & Tech Debt
INSERT INTO csuite_wiki (category, title, slug, content, tags, importance, is_public, created_by, updated_by)
VALUES (
  'operations',
  'Known Issues & Tech Debt',
  'tech-debt',
  '# Known Issues & Tech Debt

## Critical Issues 🔴

### None Currently
No blocking issues preventing core functionality.

## High Priority Issues 🟠

### 1. Performance on Mobile
- **Issue**: Some pages load slowly on mobile devices
- **Impact**: User experience, potential drop-off
- **Next Step**: Profile pages, optimize images
- **Owner**: Cody

### 2. Search Filters Not Persisting
- **Issue**: When users navigate back, filters reset
- **Impact**: Frustrating user experience
- **Next Step**: Implement URL query params
- **Owner**: Cody

## Medium Priority Issues 🟡

### 1. Email Notifications Not Implemented
- **Issue**: Users don''t get email when matches found
- **Impact**: Missed engagement opportunity
- **Next Step**: Set up Resend or SendGrid
- **Owner**: Cody + Mark

### 2. No Unsubscribe Flow
- **Issue**: Users can''t easily unsubscribe from emails
- **Impact**: Legal risk, poor UX
- **Next Step**: Add unsubscribe page
- **Owner**: Cody + Ward

## Low Priority Issues 🟢

### 1. Placeholder Images
- **Issue**: Some properties use placeholder images
- **Impact**: Looks unfinished
- **Next Step**: Get real property images
- **Owner**: Art

### 2. No Dark Mode
- **Issue**: App only has light mode
- **Impact**: User preference, accessibility
- **Next Step**: Implement theme system
- **Owner**: Cody + Art

## Tech Debt 📦

### Database
- Need to add proper indexes for search queries
- RLS policies could be more granular
- Consider caching layer for frequently accessed data

### Frontend
- Component library is inconsistent (mix of styles)
- Need to standardize error handling
- Could use better loading states

### Infrastructure
- No automated testing (unit or e2e)
- No CI/CD pipeline (manual deploys)
- Need better error tracking (Sentry?)

### Code Organization
- Some components are too large (split up)
- API routes need better error handling
- Need more consistent naming conventions

## Future Enhancements 🚀

### Phase 1 (Q1 2025)
- Email notifications
- Improved mobile performance
- Better search experience
- Admin dashboard

### Phase 2 (Q2 2025)
- Dark mode
- Real property images
- Automated testing
- Performance monitoring

### Phase 3 (Q3 2025)
- Native mobile app
- Offline support
- Advanced AI features
- Integration with property APIs

## How to Report Issues

1. **Bugs**: Create GitHub issue with steps to reproduce
2. **Feature Requests**: Discuss with Bridget first
3. **Tech Debt**: Add to this wiki page for tracking
4. **Security Issues**: Email Ryan immediately

Last updated: December 9, 2024',
  ARRAY['operations', 'tech-debt', 'issues', 'bugs', 'roadmap'],
  'high',
  true,
  'ryan@homeypocket.ai',
  'ryan@homeypocket.ai'
);

-- Success Metrics & KPIs
INSERT INTO csuite_wiki (category, title, slug, content, tags, importance, is_public, created_by, updated_by)
VALUES (
  'context',
  'Success Metrics & KPIs',
  'success-metrics',
  '# Success Metrics & KPIs

## North Star Metric
**Homes Found Through HOMEY**

This is the ultimate measure of success. Everything we do should contribute to helping more people find their perfect home.

## Primary Metrics (Track Weekly)

### User Growth
- **Active Users**: Users who logged in this week
- **Target**: 50 users by end of Dec 2024
- **Target**: 1,000 users by end of Q1 2025

### Engagement
- **Searches per User**: Avg searches per active user
- **Target**: 3+ searches per user per week
- **Properties Saved**: Avg saved homes per user
- **Target**: 5+ saved properties per user

### Retention
- **Week 1 Retention**: % of users who return after signup
- **Target**: 40%+
- **Month 1 Retention**: % of users still active after 30 days
- **Target**: 20%+

## Secondary Metrics (Track Monthly)

### Product
- **Time to First Search**: How long until user searches
- **Target**: <2 minutes
- **Feature Adoption**: % using key features
- **Target**: 60%+ using saved homes

### Technical
- **Page Load Time**: Time to interactive
- **Target**: <3 seconds
- **Error Rate**: % of requests that error
- **Target**: <1%
- **Uptime**: % of time app is accessible
- **Target**: 99.5%+

### Conversion (Future)
- **Free to Paid**: % of users who upgrade
- **Target**: 5% (when launched)
- **Lead Quality**: % of leads that realtors accept
- **Target**: 60%+

## How We Measure

### Tools
- Supabase Analytics (database queries)
- Vercel Analytics (page views, performance)
- Custom events in analytics_events table

### Reports
- **Daily**: Check active users & errors
- **Weekly**: Review engagement & retention
- **Monthly**: Deep dive on trends & cohorts

## Goals by Quarter

### Q4 2024 (Current)
- ✅ Launch C-Suite integration
- ✅ Deploy version tracking
- 🔄 Reach 50 active users
- 🔄 Get first user testimonials

### Q1 2025
- 1,000 active users
- 40% week-1 retention
- Launch premium tier
- $5k MRR

### Q2 2025
- 5,000 active users
- 50+ paying subscribers
- Partner with 3 realtors
- $20k MRR

## What Counts as Success?

### User Success
A user successfully finds and secures a home they love through HOMEY.

### Business Success
HOMEY becomes profitable and sustainable.

### Team Success
The C-Suite AI system helps Ryan make better, faster decisions.

## Red Flags to Watch

🚩 **Users signing up but not searching**
→ Onboarding issue or unclear value prop

🚩 **Users searching but not saving homes**
→ Poor recommendations or bad UX

🚩 **High week-1 churn**
→ Missing features or bad first experience

🚩 **No organic growth**
→ Product not compelling enough to share

Last updated: December 9, 2024',
  ARRAY['metrics', 'kpis', 'goals', 'success', 'tracking'],
  'high',
  true,
  'ryan@homeypocket.ai',
  'ryan@homeypocket.ai'
);
