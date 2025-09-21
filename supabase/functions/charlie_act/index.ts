// supabase/functions/charlie_act/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
const json = (b, s = 200)=>new Response(JSON.stringify(b), {
    status: s,
    headers: {
      "content-type": "application/json"
    }
  });
// tiny numeric helper
const num = (v)=>{
  const n = Number.parseFloat(String(v ?? "0"));
  return Number.isFinite(n) ? n : 0;
};
Deno.serve(async (req)=>{
  // preflight
  if (req.method === "OPTIONS") return json({
    ok: true
  });
  const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
  const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
  const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") || "";
  const authHeader = req.headers.get("Authorization") || "";
  const hasBearer = authHeader.startsWith("Bearer ");
  const jwt = hasBearer ? authHeader.slice(7) : null;
  try {
    const { action, payload } = await req.json().catch(()=>({
        action: "ping",
        payload: null
      }));
    if (action === "diag") {
      return json({
        ok: true,
        hasUrl: !!SUPABASE_URL,
        hasServiceKey: !!SERVICE_KEY,
        hasAnonKey: !!ANON_KEY,
        hasJwt: !!jwt
      });
    }
    if (action === "ping") return json({
      ok: true,
      message: "charlie_act up"
    });
    if (!jwt) return json({
      ok: false,
      error: "missing_jwt",
      hint: "Send Authorization: Bearer <USER_JWT>"
    }, 401);
    const userClient = createClient(SUPABASE_URL, ANON_KEY, {
      auth: {
        persistSession: false,
        detectSessionInUrl: false
      },
      global: {
        headers: {
          Authorization: `Bearer ${jwt}`
        }
      }
    });
    const svc = createClient(SUPABASE_URL, SERVICE_KEY, {
      auth: {
        persistSession: false
      }
    });
    const { data: u, error: uErr } = await userClient.auth.getUser();
    if (uErr || !u?.user) return json({
      ok: false,
      error: "invalid_user",
      detail: uErr?.message
    }, 401);
    const userId = u.user.id;
    // generate checklist and insert tasks
    if ([
      "generate_checklist_and_insert_tasks",
      "generate_and_save_checklist"
    ].includes(String(action))) {
      const kind = payload?.kind || "rent";
      const items = kind === "agent" ? [
        {
          id: "a1",
          text: "Signed agency disclosure",
          required: true
        },
        {
          id: "a2",
          text: "KYC verified",
          required: true
        },
        {
          id: "a3",
          text: "REBNY forms templated",
          required: false
        }
      ] : [
        {
          id: "c1",
          text: "Photo ID",
          required: true
        },
        {
          id: "c2",
          text: "Income docs (2 pay stubs / 1099)",
          required: true
        },
        {
          id: "c3",
          text: "Latest tax return",
          required: false
        },
        {
          id: "c4",
          text: "Landlord reference",
          required: false
        }
      ];
      const { data: checklist, error: clErr } = await svc.from("checklists").upsert({
        user_id: userId,
        kind,
        items
      }, {
        onConflict: "user_id,kind"
      }).select("id").maybeSingle();
      if (clErr) return json({
        ok: false,
        error: "checklist_upsert_failed",
        detail: clErr.message
      }, 500);
      const rows = items.map((it)=>({
          owner: userId,
          title: it.text,
          step: 3,
          track: "B",
          status: "to_do",
          done_criteria: it.required ? "Required" : "Optional",
          meta: {
            checklist_id: checklist?.id ?? null,
            source: "charlie_act"
          }
        }));
      const { error: tErr } = await svc.from("tasks").insert(rows);
      if (tErr) return json({
        ok: false,
        error: "tasks_insert_failed",
        detail: tErr.message
      }, 500);
      await svc.from("journey_events").insert({
        user_id: userId,
        kind: "task_created",
        meta: {
          count: rows.length,
          from: "generate_checklist_and_insert_tasks"
        }
      });
      return json({
        ok: true,
        inserted: rows.length,
        kind
      });
    }
    // compute DTI and create a task
    if (action === "compute_dti_and_create_task") {
      const income = num(payload?.monthly_income);
      const debts = num(payload?.monthly_debts);
      if (!(income > 0)) return json({
        ok: false,
        error: "bad_input",
        hint: "monthly_income must be a number > 0"
      }, 400);
      const dti = +(100 * (debts / income)).toFixed(2);
      const title = `Paige: Review DTI (${dti}%)`;
      const { error: tErr } = await svc.from("tasks").insert({
        owner: userId,
        title,
        step: 4,
        track: "B",
        status: "to_do",
        done_criteria: "Discuss affordability & docs",
        meta: {
          dti,
          monthly_income: income,
          monthly_debts: debts,
          source: "charlie_dti"
        }
      });
      if (tErr) return json({
        ok: false,
        error: "task_insert_failed",
        detail: tErr.message
      }, 500);
      await svc.from("journey_events").insert({
        user_id: userId,
        kind: "task_created",
        meta: {
          from: "compute_dti_and_create_task",
          dti
        }
      });
      return json({
        ok: true,
        dti
      });
    }
    // create invite code
    if (action === "create_invite_code") {
      // optional: restrict to agents/admins
      const { data: prof, error: profErr } = await svc.from("profiles").select("role").eq("id", userId).maybeSingle();
      if (profErr) return json({
        ok: false,
        error: "profile_lookup_failed",
        detail: profErr.message
      }, 500);
      if (!prof || ![
        "agent",
        "admin"
      ].includes(prof.role)) return json({
        ok: false,
        error: "forbidden"
      }, 403);
      const code = crypto.randomUUID().replace(/-/g, "").slice(0, 8);
      const row = {
        code,
        role: payload?.role ?? "client",
        email: payload?.email ?? null,
        created_by: userId,
        expires_at: payload?.expires_at ?? null,
        max_uses: payload?.max_uses ?? 1,
        uses: 0,
        accepted_by: []
      };
      const { data: ins, error } = await svc.from("invites").insert(row).select("id,code").maybeSingle();
      if (error) return json({
        ok: false,
        error: "invite_insert_failed",
        detail: error.message
      }, 500);
      await svc.from("journey_events").insert({
        user_id: userId,
        kind: "invite_created",
        note: code,
        meta: {
          code,
          max_uses: row.max_uses,
          role: row.role
        }
      });
      return json({
        ok: true,
        code: ins?.code ?? code
      });
    }
    // ACTION: 5B freeform -> Paige task
    if (action === "create_paige_task") {
      const title = String(payload?.title ?? "").trim().slice(0, 140);
      if (!title) return json({
        ok: false,
        error: "bad_input",
        hint: "title required"
      }, 400);
      const { data: ins, error } = await svc.from("tasks").insert({
        owner: userId,
        title: `Paige: ${title}`,
        step: 5,
        track: "B",
        status: "to_do",
        done_criteria: "Follow up",
        meta: {
          source: "charlie_paige_freeform"
        }
      }).select("id").maybeSingle();
      if (error) return json({
        ok: false,
        error: "task_insert_failed",
        detail: error.message
      }, 500);
      await svc.from("journey_events").insert({
        user_id: userId,
        kind: "task_created",
        note: title
      });
      return json({
        ok: true,
        task_id: ins?.id ?? null
      });
    }

    // ACTION: 5E nudge a client (logs an event)
if (action === "nudge_client") {
  const client_id = String(payload?.client_id ?? "").trim();
  if (!client_id) {
    return json({ ok: false, error: "bad_input", hint: "client_id required" }, 400);
  }

  // record the nudge; expand to notifications later
  const { error: jeErr } = await svc.from("journey_events").insert({
    user_id: userId,
    kind: "nudge_sent",
    note: client_id,
  });
  if (jeErr) {
    return json({ ok: false, error: "journey_event_failed", detail: jeErr.message }, 500);
  }

  return json({ ok: true });
}
    return json({
      ok: false,
      error: "unknown_action",
      action
    }, 400);
  } catch (e) {
    return json({
      ok: false,
      error: "unhandled",
      detail: String(e)
    }, 500);
  }
});
