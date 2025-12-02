# Email Invitation Setup

The agent invitation system supports multiple email providers. Choose the one that works best for you!

## Your Options

### Option 1: No Setup (Development/Testing) ✅
**Cost:** Free
**Setup:** None needed
**What happens:** Invitation links are logged to your console

This is **perfect for testing right now!** Just invite a client and copy the link from your terminal.

---

### Option 2: SendGrid (If you already have it)
**Cost:** Free tier: 100 emails/day
**Setup:** 5 minutes

If you have SendGrid (or "Spacemail" if that's what you meant), just add:

```bash
# .env.local
SENDGRID_API_KEY=SG.xxxxxxxxxxxxx
EMAIL_FROM=HOMEY <noreply@homeypocket.ai>
```

Get your API key from: https://app.sendgrid.com/settings/api_keys

---

### Option 3: Resend (Recommended) ✅
**Cost:** Free tier: 100 emails/day, 3,000/month
**Setup:** 5 minutes
**Why:** Modern, great deliverability, simple API

```bash
# .env.local
RESEND_API_KEY=re_xxxxxxxxxxxxx
EMAIL_FROM=HOMEY <onboarding@resend.dev>
```

Get your API key from: https://resend.com/api-keys

**No template creation needed!** The system sends HTML directly - just add your API key and you're ready to go.

⚠️ **Testing Limitation:** Without domain verification, Resend only allows sending to the email address associated with your Resend account.

**For Testing:**
- Send invitations to your own email (the one you used to sign up for Resend)
- You can still test the full invitation flow this way

**For Production:**
1. Verify your domain at https://resend.com/domains
2. Update `EMAIL_FROM` to use your verified domain
3. Then you can send to any email address

---

### Option 4: Supabase SMTP (Future)
**Cost:** Included with Supabase
**Setup:** Requires Edge Function (not yet implemented)

Supabase's built-in email is **only for auth emails** (password reset, etc.), not custom app emails. To use Supabase for custom emails, you'd need to:

1. Create a Supabase Edge Function
2. Configure SMTP settings in Supabase
3. Call the Edge Function from the app

**For now, use Option 1, 2, or 3 instead.**

---

## Quick Setup (Any Provider)

1. **Choose your provider** above
2. **Add the env variables** to `.env.local`
3. **Restart your dev server**
4. **Test it!** Invite a client from `/agent/clients`

## Current Behavior (No Config)

Without any email service configured:

```bash
# You'll see this in your terminal when inviting a client:
================================================================================
📧 INVITATION EMAIL (No email service configured)
================================================================================
To: client@example.com
From: John Doe (Acme Realty)
Message: Looking forward to working with you!

🔗 INVITATION LINK:
http://localhost:3000/accept-invitation?id=abc-123-xyz
================================================================================
```

Just copy that link and test it!

## Email Template

All providers use the same beautiful HTML template:
- ✨ HOMEY gradient header
- 📝 Agent name & brokerage
- 💬 Personal message (optional)
- 🔗 Big "Accept Invitation" button
- 🛡️ Safety notice

## Which One Should I Use?

**Right now (MVP/Testing)?**
→ **Option 1** (No setup) - Just copy links from console

**For production with minimal setup?**
→ **Option 3** (Resend) - Best developer experience

**If you already have SendGrid?**
→ **Option 2** (SendGrid) - No need for another service

**Want everything in Supabase?**
→ **Option 4** (Supabase) - We can set this up later when needed

## Testing the Flow

1. Go to `/agent/clients`
2. Click "Invite Client"
3. Enter any email
4. Check your terminal for the link (or email if configured)
5. Open link in incognito window
6. Sign up/login
7. Auto-connected! 🎉

## Troubleshooting

### "Email not sending"
- Check that your API key is in `.env.local`
- Restart your dev server after adding env vars
- Check console for error messages

### "Invalid API key"
- Verify you copied the full key
- Make sure there are no extra spaces
- Check that you're using the right env var name:
  - `RESEND_API_KEY` for Resend
  - `SENDGRID_API_KEY` for SendGrid

### "Still logging to console"
- Did you restart the server after adding env vars?
- Is the env var name exactly right?
- Is the key valid and active?

## Environment Variables Reference

```bash
# .env.local

# Choose ONE of these:
RESEND_API_KEY=re_xxxxxxxxxxxxx           # For Resend
SENDGRID_API_KEY=SG.xxxxxxxxxxxxx        # For SendGrid

# Required with any email service:
EMAIL_FROM=HOMEY <noreply@yourdomain.com>

# Optional (for future Supabase email):
USE_SUPABASE_EMAILS=true
SUPABASE_SERVICE_ROLE_KEY=eyJxxx...      # Already in your env
```

**Note:** The system automatically detects which service you've configured and uses it!
