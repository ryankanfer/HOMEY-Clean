# StreetEasy Share Extension for HOMEY

This guide shows how to add an iOS Share Extension so users can save StreetEasy listings directly into HOMEY from Safari or the StreetEasy app.

## Overview

- Target type: `Share Extension`
- Activation: Web URLs (`streeteasy.com`, `streeteasy.com/building`, `streeteasy.com/rental`, etc.)
- Data captured: Shared URL and optional note
- Submit: POST to HOMEY API or App Group handoff

## Steps

1. In Xcode, add a new target: `File` → `New` → `Target…` → `Share Extension`.
2. Name it `StreetEasyShareExtension` and ensure it uses the same team and bundle.
3. Enable an App Group if you prefer local handoff to the main app.
4. In the extension’s `Info.plist`, set activation rules:

```xml
<key>NSExtension</key>
<dict>
  <key>NSExtensionPointIdentifier</key>
  <string>com.apple.share-services</string>
  <key>NSExtensionAttributes</key>
  <dict>
    <key>NSExtensionActivationRule</key>
    <dict>
      <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
      <integer>1</integer>
    </dict>
  </dict>
  <key>NSExtensionMainStoryboard</key>
  <string>MainInterface</string>
</dict>
```

Optionally add host filtering via `NSExtensionActivationRule` predicate if you want to restrict to StreetEasy:

```xml
<key>NSExtensionActivationRule</key>
<string>SUBQUERY( NSExtensionItems, $item, SUBQUERY($item.attachments, $att, ANY $att.registeredTypeIdentifiers UTI-CONFORMS-TO "public.url" AND $att.NSExtensionItemAttributedContentText CONTAINS[cd] "streeteasy.com" ).@count > 0 ).@count > 0</string>
```

5. Implement `ShareViewController` to parse a URL and post to HOMEY (see sample file at `Extensions/StreetEasyShareExtension/ShareViewController.swift`).

## Sample Flow

- User opens a StreetEasy listing.
- Shares via the system sheet → chooses HOMEY.
- Extension extracts the URL from `NSExtensionItem.attachments` using `UTType.url`.
- Extension sends a POST to HOMEY’s API: `POST /v1/external-listings { source: "streeteasy", listing_url, notes }`.
- HOMEY backend enriches URL (scrape or resolve metadata) and stores it.

## Notes

- For account-based save without a backend call, use an App Group and write data to `UserDefaults(suiteName:)`, then wake HOMEY via `openURL` on a custom scheme from the main app.
- Extensions cannot directly use `UIApplication.shared`; plan cross-app communication via App Groups or backend.
- If you enrich listings, consider server-side scrapers to avoid extension complexity.

## Testing

- Run the extension target and choose Safari as host.
- Visit any `streeteasy.com` listing, trigger Share, select HOMEY.
- Verify the POST succeeds (use Charles Proxy/Proxyman or backend logs).