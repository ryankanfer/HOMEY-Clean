# HOMEY Agent-Client Integration Testing Guide

## Overview
This guide provides step-by-step instructions for testing the HOMEY app with the real estate agent-facing side (h.OS Agent) running on Vercel/Supabase.

## Supabase Configuration ✅
- **URL**: `https://mzqswvyfnblghgvcgxpw.supabase.co/`
- **Anon Key**: Configured in `Info.plist` and various service files
- **Connection**: Successfully verified and accessible

## Test User Accounts

### Agent Account
- **Email**: `testagent@gmail.com`
- **Password**: `TestAgent123!`
- **Role**: `agent`

### Client Account  
- **Email**: `testclient@gmail.com`
- **Password**: `TestClient123!`
- **Role**: `client`

## Testing Steps

### 1. Agent Dashboard Testing

1. **Open the App**
   - Launch Xcode and open `HOMEY Clean.xcodeproj`
   - Build and run the app in iOS Simulator
   - The app should show the authentication screen

2. **Sign In as Agent**
   - Use credentials: `testagent@gmail.com` / `TestAgent123!`
   - The app should detect the agent role automatically
   - You should see the Agent Dashboard interface

3. **Test Agent Features**
   - **Client List**: View and filter client profiles
   - **Invite Creation**: Create invitation codes for new clients (max 3 uses)
   - **Client Timeline**: Navigate to individual client timelines
   - **Nudge Functionality**: Send nudges to clients
   - **Events View**: Access agent events from the toolbar
   - **Search**: Test client search by name or email

### 2. Client-Agent Integration Testing

1. **Sign In as Client**
   - Sign out from agent account
   - Sign in with: `testclient@gmail.com` / `TestClient123!`
   - Should see the standard client interface

2. **Test Client Features**
   - Complete onboarding flow
   - Navigate through client tabs
   - Test signature screens and interactions

3. **Test Agent-Client Linking**
   - From agent dashboard, create an invite code
   - Use the invite code to link the client to the agent
   - Verify the connection appears in both interfaces

### 3. Real-time Features Testing

1. **Dual Device Testing** (Recommended)
   - Run app on two simulators or devices
   - One signed in as agent, one as client
   - Test real-time updates between interfaces

2. **Event Tracking**
   - Perform actions as client
   - Verify events appear in agent timeline
   - Test notification system

## Key Components Architecture

### Agent Dashboard (`AgentDashboardView.swift`)
- **Location**: `/Dashboards/Agents/AgentDashboardView.swift`
- **Features**: Client management, timeline viewing, invite creation
- **Services**: `SupabaseProfileService` for real data, `MockProfileService` for testing

### Authentication System
- **Manager**: `AppSessionManager.swift`
- **Role Detection**: Automatic based on Supabase profile data
- **Storage**: Keychain for secure token storage

### Real-time Integration
- **Service**: `RealtimeSubscriptions` in `AppSessionManager`
- **Events**: `EventsRepository` for tracking client actions
- **Notifications**: Push notification system for agent alerts

## Troubleshooting

### Common Issues

1. **Profile Not Found**
   - Ensure user signup completed successfully
   - Check Supabase profiles table for user entry
   - Verify role assignment in user metadata

2. **Authentication Errors**
   - Check Supabase URL and anon key configuration
   - Verify network connectivity
   - Clear app data and retry

3. **Role Detection Issues**
   - Check `loadRole()` function in `RootView.swift`
   - Verify profile data in Supabase
   - Test with admin role for debugging

### Debug Commands

```bash
# Check Supabase connection
python3 -c "
import requests
headers = {'apikey': 'YOUR_ANON_KEY', 'Authorization': 'Bearer YOUR_ANON_KEY'}
response = requests.get('https://mzqswvyfnblghgvcgxpw.supabase.co/rest/v1/profiles', headers=headers)
print(f'Status: {response.status_code}, Data: {response.json()}')
"

# Verify user profiles
# Use the check_admin_status.py script in the project root
```

## Next Steps

1. **Production Testing**
   - Test with real email addresses
   - Verify email confirmation flow
   - Test with production Supabase instance

2. **Performance Testing**
   - Test with multiple clients per agent
   - Verify real-time performance under load
   - Test offline/online synchronization

3. **Security Testing**
   - Verify Row Level Security (RLS) policies
   - Test unauthorized access attempts
   - Validate JWT token handling

## Support Files

- **Supabase Config**: `SupabaseClientProvider.swift`
- **Auth Manager**: `SupabaseAuthManager.swift`
- **Profile Service**: `PreferencesService.swift`
- **Events System**: `EventsManager.swift`

---

**Last Updated**: January 25, 2025
**Version**: 1.0
**Status**: Ready for Testing ✅