import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

type Json = Record<string, unknown>;

const PROJECT_URL = Deno.env.get("PROJECT_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SERVICE_ROLE_KEY")!;
const PUBLIC_ANON_KEY = Deno.env.get("PUBLIC_ANON_KEY") ?? Deno.env.get("SUPABASE_ANON_KEY") ?? "";

Deno.serve(async (req) => {
  try {
    const auth = req.headers.get("Authorization") ?? "";
    const jwt = auth.startsWith("Bearer ") ? auth.slice(7) : null;
    if (!jwt) return json({ error: "missing_jwt" }, 401);

    const body = await req.json().catch(() => ({}));
    const raw = typeof body.code === "string" ? body.code : "";
    const code = raw.trim();
    if (!code) return json({ error: "invalid_code" }, 400);

    // service client (bypasses RLS)
    const svc = createClient(PROJECT_URL, SERVICE_ROLE_KEY, { auth: { persistSession: false } });

    // user client for auth lookups
    const userClient = createClient(PROJECT_URL, PUBLIC_ANON_KEY, {
      global: { headers: { Authorization: `Bearer ${jwt}`, apikey: PUBLIC_ANON_KEY } },
      auth: { persistSession: false }
    });

    // who is this
    const { data: { user }, error: userErr } = await userClient.auth.getUser();
    if (userErr || !user) return json({ error: "invalid_user", detail: userErr?.message ?? null }, 401);

    // load invite (case-insensitive, force single)
    const { data: invite, error: invErr } = await svc
      .from("invites")
      .select("id, code, role, expires_at, max_uses, uses, accepted_by")
      .ilike("code", code)
      .limit(1)
      .single();
    if (invErr || !invite) return json({ error: "not_found", detail: invErr?.message ?? null }, 404);

    // validate
    if (invite.expires_at && new Date(invite.expires_at) < new Date()) return json({ error: "expired" }, 400);
    if (invite.max_uses !== null && invite.max_uses !== undefined && (invite.uses ?? 0) >= invite.max_uses) return json({ error: "maxed_out" }, 400);
    if (Array.isArray(invite.accepted_by) && invite.accepted_by.includes(user.id)) {
      return json({ ok: true, code: invite.code, role: invite.role, already: true });
    }

    // derive a safe, non-empty display_name
    const displayName =
      (user.user_metadata && (user.user_metadata.display_name || user.user_metadata.full_name)) ||
      (user.email ? user.email.split("@")[0] : null) ||
      "User";

    // upsert profile with a real display_name so the CHECK passes
    const { error: upErr } = await svc
      .from("profiles")
      .upsert(
        {
          id: user.id,
          email: user.email ?? null,
          role: invite.role,
          display_name: displayName,
          updated_at: new Date().toISOString()
        },
        { onConflict: "id" }
      );
    if (upErr) return json({ error: "profile_upsert_failed", detail: upErr.message }, 500);

    // bump uses and append user to accepted_by[]
    const nextUses = (invite.uses ?? 0) + 1;
    const nextAccepted = Array.isArray(invite.accepted_by) ? [...invite.accepted_by, user.id] : [user.id];
    const { error: updErr } = await svc
      .from("invites")
      .update({ uses: nextUses, accepted_by: nextAccepted })
      .eq("id", invite.id);
    if (updErr) return json({ error: "invite_update_failed", detail: updErr.message }, 500);

    return json({ ok: true, code: invite.code, role: invite.role });
  } catch (e) {
    return json({ error: "server_error", detail: String(e) }, 500);
  }
});

function json(body: Json, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json; charset=utf-8" } });
}
