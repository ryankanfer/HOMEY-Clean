chrome.action.onClicked.addListener(async (tab) => {
  if (!tab.id) return;
  try {
    await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      files: ["content.js"]
    });
    // Ask the content script for data
    const [resp] = await chrome.tabs.sendMessage(tab.id, { type: "HOMEY_COLLECT" });
    if (resp && resp.payload) {
      // Build universal link (replace with your domain if different)
      const u = new URL("https://homey.app/ingest");
      u.searchParams.set("url", resp.payload.url || tab.url || "");
      // attach a JSON payload (short) — URL-encode to be safe
      const short = {
        address: resp.payload.address || "",
        price: resp.payload.price || "",
        beds: resp.payload.beds || "",
        baths: resp.payload.baths || "",
        sqft: resp.payload.sqft || "",
        source: resp.payload.source || ""
      };
      u.searchParams.set("meta", encodeURIComponent(JSON.stringify(short)));
      // Open in a new tab (desktop) — Safari app extension will route into the app on iOS
      await chrome.tabs.create({ url: u.toString() });
    } else {
      console.warn("No payload from content.js");
    }
  } catch (e) {
    console.error("HOMEY Save Listing failed:", e);
  }
});
