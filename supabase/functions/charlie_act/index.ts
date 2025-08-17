/// <reference types="jsr:@supabase/functions-js/edge-runtime.d.ts" />

Deno.serve(async (req) => {
  try {
    const { action, payload } = await req.json().catch(() => ({ action: "ping", payload: {} }));

    // 2/B: generate_doc_checklist
    if (action === "generate_doc_checklist") {
      const role = (payload?.role as string) || "client";
      const items =
        role === "agent"
          ? [
              { id: "a1", text: "Signed agency disclosure", required: true },
              { id: "a2", text: "Client ID verified (KYC)", required: true },
              { id: "a3", text: "REBNY forms templated", required: false },
            ]
          : [
              { id: "c1", text: "Photo ID", required: true },
              { id: "c2", text: "Last 2 pay stubs or 1099", required: true },
              { id: "c3", text: "Most recent tax return", required: false },
              { id: "c4", text: "Landlord reference", required: false },
            ];

      return new Response(JSON.stringify({ ok: true, checklist: items }), {
        headers: { "content-type": "application/json" },
      });
    }

    // default stub (only hit if no action matched)
    return new Response(JSON.stringify({ ok: true, action, message: "charlie_act stub", payload }), {
      headers: { "content-type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, error: "bad_request", detail: String(e) }), {
      status: 400,
      headers: { "content-type": "application/json" },
    });
  }
});
