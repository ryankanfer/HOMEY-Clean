/// <reference types="jsr:@supabase/functions-js/edge-runtime.d.ts" />

Deno.serve(async (req) => {
  try {
    const { action, payload } = await req.json().catch(() => ({ action: "ping", payload: null }));
    return new Response(
      JSON.stringify({ ok: true, action, message: "charlie_act stub", payload }),
      { headers: { "content-type": "application/json" } }
    );
  } catch (_e) {
    return new Response(
      JSON.stringify({ ok: false, error: "bad_request" }),
      { status: 400, headers: { "content-type": "application/json" } }
    );
  }
});
