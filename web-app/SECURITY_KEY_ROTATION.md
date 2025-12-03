# 🔐 API Key Rotation Guide

## ⚠️ URGENT: Your API keys need to be rotated immediately

Your `.env.local` file contains production credentials that should be rotated for security best practices. While they haven't been committed to git, they exist on your local machine and any backups.

---

## 📋 Keys That Need Rotation

### 1. Supabase Keys (CRITICAL)

**Current Keys to Rotate:**
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

**Steps to Rotate:**

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `mzqswvyfnblghgvcgxpw`
3. Navigate to **Settings** → **API**
4. Under "Project API keys":
   - **Anon key**: Copy the existing key, you'll use it temporarily
   - **Service role key**: Copy the existing key

5. **Generate New Keys** (if Supabase supports it) OR create a new project:
   - If rotating keys isn't supported, consider:
     - Creating a new Supabase project
     - Migrating your database
     - Updating all references

6. Update `.env.local`:
   ```bash
   NEXT_PUBLIC_SUPABASE_ANON_KEY=new_anon_key_here
   SUPABASE_SERVICE_ROLE_KEY=new_service_role_key_here
   ```

7. Update Vercel environment variables:
   - Go to your Vercel project settings
   - Environment Variables section
   - Update both keys
   - Redeploy

**Impact:** All existing client sessions will be invalidated. Users will need to log in again.

---

### 2. OpenAI API Key (HIGH PRIORITY)

**Current Key Format:** `sk-proj-...`

**Steps to Rotate:**

1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. **Delete** the old key:
   - Find the key starting with `sk-proj-5Fyi0ioG895slaQXghUg...`
   - Click "Revoke"
   - Confirm deletion

3. **Create** new key:
   - Click "Create new secret key"
   - Name it: `homey-production-{current-date}`
   - Copy the key immediately (you won't see it again)

4. Update `.env.local`:
   ```bash
   OPENAI_API_KEY=sk-proj-NEW_KEY_HERE
   ```

5. Update Vercel:
   - Settings → Environment Variables
   - Update `OPENAI_API_KEY`
   - Redeploy

**Impact:** Document extraction will fail until new key is deployed. Plan rotation during low-traffic period.

---

### 3. RapidAPI Key (MEDIUM PRIORITY)

**Current Key:** `94cae68f50mshd9073cc3c375b38p1b2c1fjsna61f908f34d3`

**Steps to Rotate:**

1. Go to [RapidAPI Dashboard](https://rapidapi.com/developer/security)
2. Under "Application Keys":
   - Find your current app
   - Click "Regenerate" or create new application

3. Update `.env.local`:
   ```bash
   NEXT_PUBLIC_RAPIDAPI_KEY=new_key_here
   ```

4. Update Vercel environment variables
5. Redeploy

**Impact:** Real estate data sync will fail until updated.

---

### 4. PDF.co API Key (MEDIUM PRIORITY)

**Current Key:** `kanfer.ryan@gmail.com_zInaeGjAj8zsgcE3CdACWN06...`

**Steps to Rotate:**

1. Go to [PDF.co Dashboard](https://app.pdf.co/)
2. Navigate to API Keys section
3. Revoke old key
4. Generate new key

5. Update `.env.local`:
   ```bash
   PDF_CO_API_KEY=new_key_here
   ```

6. Update Vercel
7. Redeploy

**Impact:** PDF to image conversion will fail. Document uploads will be affected.

---

### 5. Resend API Key (LOW PRIORITY - Email)

**Current Key:** `re_GPDigPfK_MTfzMzsvKA91epCUMY3RtbCQ`

**Steps to Rotate:**

1. Go to [Resend Dashboard](https://resend.com/api-keys)
2. Delete old API key
3. Create new key with same permissions

4. Update `.env.local`:
   ```bash
   RESEND_API_KEY=re_NEW_KEY_HERE
   ```

5. Update Vercel
6. Redeploy

**Impact:** Email notifications will fail until updated.

---

### 6. Mapbox Token (LOW PRIORITY - Maps)

**Current Token:** `pk.ey...` (partial in env)

**Steps to Rotate:**

1. Go to [Mapbox Account](https://account.mapbox.com/access-tokens/)
2. Revoke old token
3. Create new token with same scopes:
   - ✓ Read token
   - ✓ Vector tiles
   - ✓ Styles

4. Update `.env.local`:
   ```bash
   NEXT_PUBLIC_MAPBOX_TOKEN=pk.NEW_TOKEN_HERE
   ```

5. Update Vercel
6. Redeploy

**Impact:** Maps will not load until updated.

---

### 7. Rentcast API Key (MEDIUM PRIORITY)

**Steps to Rotate:**

1. Go to Rentcast dashboard
2. Regenerate API key
3. Update `.env.local` and Vercel

---

## 🚨 Rotation Priority Order

### Immediate (Do Today):
1. **Supabase Service Role Key** - Full database admin access
2. **OpenAI API Key** - High usage, billing impact
3. **Supabase Anon Key** - User authentication

### This Week:
4. **RapidAPI Key** - External data access
5. **PDF.co API Key** - Document processing
6. **Rentcast API Key** - Property data

### When Convenient:
7. **Resend API Key** - Email notifications
8. **Mapbox Token** - Map displays

---

## 📝 Post-Rotation Checklist

After rotating all keys:

- [ ] All keys updated in `.env.local`
- [ ] All keys updated in Vercel environment variables
- [ ] Application deployed with new keys
- [ ] Test critical workflows:
  - [ ] User login/signup
  - [ ] Document upload and extraction
  - [ ] Property search and listing sync
  - [ ] Map display
  - [ ] Email sending (if applicable)
- [ ] Monitor error logs for 24 hours
- [ ] Check API usage dashboards for anomalies

---

## 🔒 Ongoing Security Best Practices

### 1. Never Commit Secrets to Git

Always check before committing:
```bash
git status
git diff .env.local  # Should show "not staged"
```

### 2. Use Environment-Specific Keys

- **Development**: Use test/sandbox keys
- **Staging**: Use staging-specific keys
- **Production**: Use production keys (never share across environments)

### 3. Rotate Keys Regularly

Set calendar reminders:
- **Critical keys**: Every 90 days
- **Standard keys**: Every 180 days
- **Low-risk keys**: Annually

### 4. Monitor API Usage

Check dashboards weekly:
- OpenAI: [Usage Dashboard](https://platform.openai.com/usage)
- Supabase: [Database Dashboard](https://supabase.com/dashboard)
- RapidAPI: [Usage Stats](https://rapidapi.com/developer/billing)

### 5. Implement Key Rotation Automation

Consider using:
- **AWS Secrets Manager** with automatic rotation
- **HashiCorp Vault** for enterprise setups
- **Vercel's secret management** with rotation policies

---

## 🆘 If Keys Are Compromised

If you suspect a key has been exposed:

1. **Immediately revoke the key** in the provider's dashboard
2. **Generate a new key**
3. **Update all environments** (local, staging, production)
4. **Monitor for unusual activity**:
   - Check API usage for spikes
   - Review database logs for unauthorized access
   - Check billing for unexpected charges
5. **Document the incident**:
   - What key was exposed?
   - How was it exposed?
   - When was it rotated?
   - Any damage assessment?

---

## 📞 Support Contacts

If you need help during rotation:

- **Supabase**: support@supabase.io
- **OpenAI**: help.openai.com
- **RapidAPI**: rapidapi.com/support
- **Vercel**: vercel.com/support

---

## ✅ Verification After Rotation

Test these endpoints after deploying new keys:

1. **Authentication**: `POST /api/auth/signup`
2. **Document Upload**: `POST /api/documents/extract`
3. **Listing Sync**: `POST /api/sync-listings`
4. **User Locations**: `GET /api/user/locations`

All should return successful responses (not 401 Unauthorized).

---

**Last Updated**: {DATE}
**Next Scheduled Rotation**: {DATE + 90 days}
