# Real Estate Data API Integration

## Overview

HOMEY integrates with multiple real estate data providers to fetch live property listings:

- **RapidAPI (Zillow)** - Primary data source
- **Rentcast** - Fallback for rental properties

## Setup

### 1. Get API Keys

**RapidAPI (Zillow)**
1. Go to https://rapidapi.com/s.mahmoud97/api/zillow-com1
2. Sign up and subscribe (Free tier: 500 requests/month)
3. Copy your API key

**Rentcast (Optional)**
1. Go to https://app.rentcast.io/app/api-keys
2. Sign up and create an API key
3. Copy your key

### 2. Configure Environment Variables

Add your API keys to `.env.local`:

```bash
# RapidAPI - Zillow Data (Primary)
NEXT_PUBLIC_RAPIDAPI_KEY=your_rapidapi_key_here
NEXT_PUBLIC_RAPIDAPI_HOST=zillow-com1.p.rapidapi.com

# Rentcast API (Fallback)
NEXT_PUBLIC_RENTCAST_KEY=your_rentcast_key_here
```

## Usage

### Client-Side (Manual Refresh)

Users can click the refresh button (🔄) in the home page header to fetch fresh listings.

```typescript
import searchRealEstateData from '@/lib/api/realEstateAPI';

// Fetch listings
const listings = await searchRealEstateData({
  location: 'New York, NY',
  status_type: 'ForRent',
  minPrice: 3000,
  maxPrice: 7000,
  beds_min: 2,
  page: 1,
});
```

### Server-Side (Automated Sync)

Use the sync API endpoint to automatically refresh listings on a schedule.

**Manual Trigger:**
```bash
curl -X POST http://localhost:3000/api/sync-listings \
  -H "Content-Type: application/json" \
  -d '{"location": "New York, NY", "status_type": "ForRent"}'
```

**Automated with Vercel Cron:**

Create `vercel.json`:
```json
{
  "crons": [
    {
      "path": "/api/sync-listings",
      "schedule": "0 */6 * * *"
    }
  ]
}
```

This runs every 6 hours.

**Automated with GitHub Actions:**

Create `.github/workflows/sync-listings.yml`:
```yaml
name: Sync Listings
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:  # Manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger sync
        run: |
          curl -X POST https://your-app.vercel.app/api/sync-listings \
            -H "Content-Type: application/json" \
            -d '{"location": "New York, NY"}'
```

## API Reference

### `searchRealEstateData(params)`

Fetches listings from external APIs and transforms them to HOMEY format.

**Parameters:**
```typescript
interface PropertySearchParams {
  location: string;              // e.g., "New York, NY"
  status_type?: 'ForSale' | 'ForRent';
  home_type?: string;            // e.g., "Apartments"
  minPrice?: number;
  maxPrice?: number;
  beds_min?: number;
  baths_min?: number;
  page?: number;
}
```

**Returns:**
```typescript
Promise<Listing[]>
```

### `transformAPIPropertyToListing(apiProperty)`

Transforms raw API response to HOMEY Listing format.

**Input:** Raw API property object
**Output:** Listing object with all HOMEY fields

## Data Flow

```
External API (Zillow/Rentcast)
  ↓
searchRealEstateData()
  ↓
transformAPIPropertyToListing()
  ↓
Save to Supabase (listings table)
  ↓
Display in HOMEY feed
```

## Error Handling

The API integration includes multiple layers of error handling:

1. **Provider Fallback**: If RapidAPI fails, automatically tries Rentcast
2. **Client Error Display**: Shows user-friendly error messages
3. **Server Logging**: Logs detailed errors for debugging
4. **Graceful Degradation**: Falls back to cached database listings if APIs fail

## Rate Limits

**RapidAPI Free Tier:**
- 500 requests/month
- ~16 requests/day
- Recommendation: Sync every 6 hours (4 times/day)

**Rentcast Free Tier:**
- 500 requests/month
- Similar limits to RapidAPI

## Best Practices

1. **Cache First**: Always load from database first, then refresh
2. **Dedupe by external_id**: Prevent duplicate listings
3. **Mark Inactive**: Set `is_active=false` for delisted properties
4. **Track Source**: Store `source` field to identify data provider
5. **Monitor Usage**: Track API call count to stay within limits
6. **Batch Updates**: Sync multiple cities in one API call when possible

## Monitoring

Track API usage and sync health:

```sql
-- Check latest sync
SELECT source, COUNT(*), MAX(created_at) as last_sync
FROM listings
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY source;

-- Active listings by source
SELECT source, COUNT(*) as active_count
FROM listings
WHERE is_active = true
GROUP BY source;
```

## Troubleshooting

**"No API keys configured" error:**
- Check `.env.local` has API keys
- Restart dev server after adding keys

**"Failed to fetch listings" error:**
- Verify API keys are valid
- Check API quota hasn't been exceeded
- Test API directly in RapidAPI dashboard

**Duplicate listings:**
- Ensure `external_id` is being set correctly
- Check deduplication logic in sync function

---

**Built for AI-first real estate.** Every listing powers the HOMEY intelligence network.
