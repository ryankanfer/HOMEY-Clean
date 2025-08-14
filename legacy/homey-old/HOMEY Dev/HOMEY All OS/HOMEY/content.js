(function() {
  function text(el) { return (el && el.textContent || "").trim(); }
  function pick(selector) { const el = document.querySelector(selector); return el ? text(el) : ""; }
  function og(name) { const el = document.querySelector(`meta[property="og:${name}"]`); return el ? el.getAttribute("content") || "" : ""; }
  function meta(name) { const el = document.querySelector(`meta[name="${name}"]`); return el ? el.getAttribute("content") || "" : ""; }

  function extractHeuristics() {
    const host = location.host;
    let price = "";
    let address = "";
    let beds = "";
    let baths = "";
    let sqft = "";
    // Try obvious meta first
    address = og("title") || meta("twitter:title") || document.title;

    // Basic sweeps for money and bd/ba/sqft on page
    const bodyText = document.body.innerText || "";
    const priceMatch = bodyText.match(/[$€£]\s?\d{1,3}(?:[,.]\d{3})+/);
    price = priceMatch ? priceMatch[0] : "";
    const bdMatch = bodyText.match(/(\d+(?:\.\d+)?)\s?(?:bd|br|bed)/i);
    beds = bdMatch ? bdMatch[1] : "";
    const baMatch = bodyText.match(/(\d+(?:\.\d+)?)\s?(?:ba|bath)/i);
    baths = baMatch ? baMatch[1] : "";
    const sqftMatch = bodyText.match(/(\d{3,5})\s?(?:sq\s?ft|ft²)/i);
    sqft = sqftMatch ? sqftMatch[1] : "";

    // StreetEasy selectors (best-effort)
    if (host.includes("streeteasy.com")) {
      address = pick("[data-qa='property-address']") || address;
      const p1 = pick("[data-qa='price']") || pick(".DetailsSummary-price");
      if (p1) price = p1;
    }
    // Zillow selectors (best-effort)
    if (host.includes("zillow.com")) {
      const zAddr = pick("h1[data-test='bdp-building-title']") || pick("h1[data-testid='bdp-building-title']");
      if (zAddr) address = zAddr;
      const zPrice = pick("[data-testid='price']") || pick("span[data-test='price']");
      if (zPrice) price = zPrice;
    }

    return {
      url: location.href,
      source: host,
      address, price, beds, baths, sqft
    };
  }

  chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
    if (msg && msg.type === "HOMEY_COLLECT") {
      const payload = extractHeuristics();
      sendResponse({ ok: true, payload });
    }
    return true;
  });
})();
