HOMEY Safari Web Extension — "Save Listing"
What it does
- Adds a toolbar button in Safari (desktop/iPad/iPhone).
- On user tap, content.js extracts visible fields (address/price/beds/baths/sqft) from StreetEasy/Zillow.
- background.js opens a universal link like https://homey.app/ingest?url=...&meta=... which your app handles to open Scout.

How to build for Safari
1) In Terminal on macOS, run: xcrun safari-web-extension-converter 6_safari_web_extension_capture --app-name "HOMEY Save Listing"
   - Choose "Convert to macOS and iOS (Safari) App Extension"
   - This creates an Xcode project with a container app + Safari Web Extension targets.
2) In Xcode:
   - Set your Team, Bundle IDs, and App Group if you want to message your main app.
   - Add Associated Domains (applinks:homey.app) so the universal link routes into HOMEY on device.
   - Build & run. Enable the extension in Safari: Preferences → Extensions (macOS) or Settings → Safari → Extensions (iOS).

Notes
- Host permissions are limited to streeteasy.com and zillow.com by design.
- All data capture is user-initiated (toolbar click). No background crawling.
- Tweak selectors in content.js to match any DOM changes over time.
- If you want to hand off via custom scheme (homey://ingest), swap the URL in background.js.
