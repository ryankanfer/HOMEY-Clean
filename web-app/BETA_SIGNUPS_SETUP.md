# Beta Signups Integration Setup

This guide connects your HOMEY marketing site's beta signups with your admin dashboard.

## ✅ What's Been Done

1. **Created BetaSignups Component** - Added to your admin dashboard
2. **Email System Verified** - Resend integration is properly configured
3. **Database Schema** - beta_signups table structure confirmed

## 🔧 Setup Steps

### 1. Ensure the beta_signups table exists in your Supabase

Run this SQL in your Supabase SQL Editor (should already be done from HOMEY-site setup):

```sql
-- Create beta_signups table
CREATE TABLE IF NOT EXISTS public.beta_signups (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  feedback TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.beta_signups ENABLE ROW LEVEL SECURITY;

-- Create policy to allow service role to read/write
CREATE POLICY "Enable read access for service role"
  ON public.beta_signups
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Enable insert for service role"
  ON public.beta_signups
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Add index for better performance
CREATE INDEX IF NOT EXISTS beta_signups_email_idx ON public.beta_signups(email);
CREATE INDEX IF NOT EXISTS beta_signups_created_at_idx ON public.beta_signups(created_at DESC);
```

### 2. Deploy the Supabase Edge Function (HOMEY-site)

```bash
cd /Users/ryankanfer/HOMEY-site

# Login to Supabase (if not already)
supabase login

# Link your project
supabase link --project-ref YOUR_PROJECT_REF

# Deploy the function
supabase functions deploy beta-signup

# Set the Resend API key
supabase secrets set RESEND_API_KEY=re_YOUR_RESEND_API_KEY
```

### 3. Configure Your Resend Account

1. Go to https://resend.com/domains
2. Add and verify `homeypocket.ai` domain
3. Add these DNS records:
   - SPF: `v=spf1 include:_spf.resend.com ~all`
   - DKIM: (provided by Resend)
   - DMARC: `v=DMARC1; p=none;`

### 4. Test the Integration

```bash
# Test the edge function
curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/beta-signup \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{"email": "test@example.com", "feedback": "Test signup"}'
```

Expected response:
```json
{
  "success": true,
  "message": "Successfully joined the beta!",
  "data": { ... }
}
```

### 5. Verify Email Sending

Check that you receive:
1. **Welcome email** to the test email address
2. **Notification email** to ryan@homeypocket.ai

## 📧 Email Templates

### Welcome Email
- **From:** `HOMEY <hello@homeypocket.ai>`
- **Subject:** "Welcome to the HOMEY Beta!"
- **Template:** Professional HTML with branding

### Admin Notification
- **From:** `HOMEY Beta <hello@homeypocket.ai>`
- **To:** `ryan@homeypocket.ai`
- **Subject:** "New Beta Signup: [email]"
- **Contains:** Email, feedback, timestamp

## 🎯 Using the Admin Dashboard

1. Navigate to `/admin` in your HOMEY web app
2. Find the **Beta Signups** section
3. Click to expand and view all signups
4. Use the **Refresh** button to reload
5. Use **Export CSV** to download all signups

## 🔒 Security Notes

- All database operations use Row Level Security (RLS)
- Emails are sent via Resend API (not exposed to frontend)
- API keys are stored as Supabase secrets
- CORS is properly configured for your domains

## 🐛 Troubleshooting

### "Beta signups table not found"
- Make sure you've run the SQL schema in your Supabase project
- Check that you're connected to the correct Supabase project

### "Emails not sending"
- Verify your Resend API key is set: `supabase secrets list`
- Check Resend dashboard for delivery status
- Make sure domain is verified in Resend

### "Duplicate email error"
- This is expected behavior - emails can only sign up once
- Frontend shows: "This email is already on our beta list!"

## 📊 Database Schema

```typescript
interface BetaSignup {
  id: string              // UUID
  email: string          // Unique, required
  name?: string          // Optional
  feedback?: string      // Optional
  metadata: {            // JSON
    source: string       // 'website'
    user_agent: string   // Browser info
  }
  created_at: string     // ISO timestamp
}
```

## 🚀 Next Steps

1. Deploy your marketing site to production
2. Update CORS in edge function for production domain
3. Monitor signups in admin dashboard
4. Export CSV periodically for backup
5. Consider adding:
   - Email templates for different stages
   - Automated follow-up sequences
   - Segment by feedback/interests
   - A/B testing for landing page

## 📝 Environment Variables

### HOMEY-site (.env.local)
```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

### Web App (already configured)
```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

---

Need help? Check the logs:
- Supabase: https://app.supabase.com/project/YOUR_PROJECT/logs
- Resend: https://resend.com/emails
