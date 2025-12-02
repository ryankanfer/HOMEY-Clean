# HOMEY Web App 🏠

Modern web application for HOMEY - Your Home Journey Companion. Built with Next.js 15, TypeScript, Tailwind CSS, and Supabase.

## ✨ Features 

- **🔐 Authentication** - Email/password, Google, and Apple sign-in
- **🎨 Glass Morphism Design** - Beautiful frosted glass UI elements
- **🌅 Time-of-Day Theming** - Dynamic backgrounds (Sunrise, Day, Sunset, Night)
- **📱 Responsive Design** - Works seamlessly on desktop and mobile
- **⚡ Next.js 15** - Latest features with App Router
- **🎭 Framer Motion** - Smooth animations and transitions
- **🗄️ Supabase** - Backend as a service (already configured from iOS app!)

## 🏗️ Tech Stack 

- **Framework:** Next.js 15 with App Router
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Animations:** Framer Motion
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Realtime)
- **Deployment:** Vercel (recommended)

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ and npm
- Supabase account (you already have one from your iOS app!)

### Installation

1. **Navigate to the web-app directory:**
   ```bash
   cd web-app
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.local.example .env.local
   ```

   Then edit `.env.local` and add your Supabase credentials:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://mzqswvyfnblghgvcgxpw.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
   ```

4. **Run the development server:**
   ```bash
   npm run dev
   ```

5. **Open your browser:**
   Navigate to [http://localhost:3000](http://localhost:3000)

## 📁 Project Structure

```
web-app/
├── app/                    # Next.js App Router
│   ├── dashboard/          # Dashboard page
│   ├── globals.css         # Global styles
│   ├── layout.tsx          # Root layout
│   └── page.tsx            # Login page (home)
├── components/             # React components
│   ├── AuroraBackground.tsx
│   ├── CinematicBackground.tsx
│   └── SceneCard.tsx
├── lib/                    # Utilities and helpers
│   └── supabase.ts         # Supabase client & helpers
├── public/                 # Static assets
├── .env.local.example      # Environment variables template
├── next.config.ts          # Next.js configuration
├── tailwind.config.ts      # Tailwind CSS configuration
└── tsconfig.json           # TypeScript configuration
```

## 🎯 Signature Scenes

The dashboard includes all 6 signature scenes from the iOS app:

1. **🔍 Scout** - Property search with AR and map visualization
2. **👥 Drew** - Professional network directory
3. **📊 Isla** - Market insights and analytics
4. **🎨 Viza** - 2D/3D interior visualization
5. **📄 Paige** - Document management
6. **💬 Charlie** - AI companion and assistant

## 🔗 Supabase Integration

The web app uses the **same Supabase backend** as your iOS app, so:

✅ User accounts work across both platforms
✅ Data is synced in real-time
✅ No migration needed - it's plug-and-play!

### Setting up Supabase:

Your Supabase project is already configured! Just add your credentials to `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://mzqswvyfnblghgvcgxpw.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
```

You can find these in your [Supabase Dashboard](https://app.supabase.com) → Settings → API.

## 🎨 Design System

### Colors
- **Primary:** Purple (`#9333ea`)
- **Glass Effects:** Frosted glass with backdrop blur
- **Time-based Gradients:**
  - Sunrise: `#8fd7ff → #a9c3ff → #bff6ea`
  - Day: `#9fd9ff → #b7e0ff → #e5fff9`
  - Sunset: `#fa8c72 → #b28cd9 → #334d80`
  - Night: `#0d1226 → #0f132e → #08080f`

### Typography
- **Font:** Josefin Sans (matching iOS app)
- **Weights:** Light (300), Semibold (600), Bold (700)

## 📦 Available Scripts

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm start        # Start production server
npm run lint     # Run ESLint
```

## 🚢 Deployment

### Deploy to Vercel (Recommended)

1. Push your code to GitHub
2. Import your repository in [Vercel](https://vercel.com)
3. Add environment variables in Vercel dashboard
4. Deploy!

Vercel will automatically:
- Build your Next.js app
- Set up SSL certificates
- Provide a production URL
- Enable automatic deployments on push

### Environment Variables for Production

Make sure to add these in your Vercel/hosting dashboard:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## 🔄 Migration Notes

This web app is designed to work **alongside** your iOS app, not replace it:

- ✅ **Shared Backend:** Same Supabase database
- ✅ **Cross-Platform Auth:** Users can sign in on both iOS and web
- ✅ **Real-time Sync:** Data updates instantly across platforms
- ✅ **Progressive Enhancement:** Start simple, add features gradually

## 🛣️ Roadmap

### Phase 1: Core Features ✅
- [x] Authentication (email, Google, Apple)
- [x] Dashboard with signature scenes
- [x] Time-of-day theming
- [x] Glass morphism design
- [x] Responsive layout

### Phase 2: Scene Implementation (Next)
- [ ] Scout - Property search and map
- [ ] Drew - Professional directory
- [ ] Isla - Market insights
- [ ] Viza - Visualization tools
- [ ] Paige - Document management
- [ ] Charlie - AI chat companion

### Phase 3: Advanced Features
- [ ] Real-time notifications
- [ ] WebRTC for video calls
- [ ] Progressive Web App (PWA)
- [ ] Offline support
- [ ] Push notifications

## 📝 License

Private - All rights reserved

## 🤝 Contributing

This is a private project for the HOMEY platform.

---

**Built with ❤️ using Next.js, TypeScript, and Supabase**
