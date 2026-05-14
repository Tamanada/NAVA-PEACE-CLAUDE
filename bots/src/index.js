/* ═══════════════════════════════════════════════════════════════════
   NAVA PEACE — Telegram Bots  (Cloudflare Worker)
   ─────────────────────────────────────────────────────────────────
   BOT 1 · Daily Reminder   → cron 0 17 * * * (midnight Bangkok)
   BOT 2 · Referral Notif   → POST /referral  (Supabase webhook)
   BOT 3 · Admin Alert      → cron 0 * * * *  (every hour)
   ═══════════════════════════════════════════════════════════════════ */

const SB_URL   = 'https://qvbxcxehhenpifhclhvs.supabase.co';
const ADMIN_ID = '788992758';
const APP_URL  = 'https://nava-peace.app';

// ── Helpers ───────────────────────────────────────────────────────────────────

function sbH(env, useServiceKey = false) {
  const key = useServiceKey ? env.SUPABASE_SERVICE_KEY : env.SUPABASE_KEY;
  return {
    'apikey':        key,
    'Authorization': 'Bearer ' + key,
    'Content-Type':  'application/json',
  };
}

async function sbGet(path, env, useServiceKey = false) {
  const r = await fetch(`${SB_URL}/rest/v1/${path}`, { headers: sbH(env, useServiceKey) });
  if (!r.ok) return [];
  return r.json();
}

async function tgSend(chatId, text, env, extra = {}) {
  const body = { chat_id: String(chatId), text, parse_mode: 'HTML', ...extra };
  const r = await fetch(`https://api.telegram.org/bot${env.BOT_TOKEN}/sendMessage`, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify(body),
  });
  const json = await r.json();
  // Handle Telegram rate limit (429)
  if (!json.ok && json.error_code === 429) {
    const wait = (json.parameters?.retry_after || 2) * 1000;
    await new Promise(res => setTimeout(res, wait));
    // One retry
    const r2 = await fetch(`https://api.telegram.org/bot${env.BOT_TOKEN}/sendMessage`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
    });
    return r2.json();
  }
  return json;
}

function todayUTC()  { return new Date().toISOString().split('T')[0]; }
function hoursAgo(n) { return new Date(Date.now() - n * 3600000).toISOString(); }

function bkkTime() {
  return new Date().toLocaleTimeString('en-GB', {
    hour: '2-digit', minute: '2-digit', timeZone: 'Asia/Bangkok'
  });
}
function bkkDate() {
  return new Date().toLocaleDateString('en-GB', {
    day: '2-digit', month: 'long', year: 'numeric', timeZone: 'Asia/Bangkok'
  }).toUpperCase();
}

// ── BOT 1 — Daily Reminder ────────────────────────────────────────────────────

async function dailyReminder(env) {
  const TODAY = todayUTC();

  // 1. All users with a linked Telegram ID (isolated table, service key)
  const allVotes = await sbGet(
    'user_telegram?select=user_uid,telegram_id',
    env, true
  );
  if (!allVotes.length) return;

  // Deduplicate — one telegram_id per user_uid
  const users = new Map();
  for (const v of allVotes) {
    if (v.telegram_id && !users.has(v.user_uid)) users.set(v.user_uid, v.telegram_id);
  }

  // 2. Users who already voted today
  const votedRows = await sbGet(
    `peace_votes?select=user_uid&created_at=gte.${TODAY}T00:00:00Z`,
    env
  );
  const votedSet = new Set(votedRows.map(v => v.user_uid));

  // 3. Send only to those who haven't voted yet
  const pending = [...users.entries()].filter(([uid]) => !votedSet.has(uid));
  let sent = 0;

  for (const [, tgId] of pending) {
    await tgSend(tgId,
      `🕊️ <b>NAVA PEACE</b>\n\n` +
      `${bkkDate()}\n\n` +
      `Your peace vote is waiting.\n` +
      `Thousands are choosing peace today — join them.`,
      env,
      {
        reply_markup: {
          inline_keyboard: [[
            { text: '🕊️ Vote for Peace Now', web_app: { url: `${APP_URL}/peace.html` } }
          ]]
        }
      }
    );
    sent++;
    // Stay well under Telegram rate limit (30 msg/s)
    if (sent % 20 === 0) await new Promise(r => setTimeout(r, 700));
  }

  // Admin summary
  await tgSend(ADMIN_ID,
    `📬 <b>Daily Reminder Sent</b>  ·  ${bkkDate()}\n\n` +
    `• Total members: <b>${users.size}</b>\n` +
    `• Already voted: <b>${votedSet.size}</b>\n` +
    `• Reminders sent: <b>${sent}</b>`,
    env
  );
}

// ── BOT 2 — Referral Notification ────────────────────────────────────────────
// Cron: * * * * * (every minute — polls new referral_points rows)
// Uses Cloudflare KV to avoid sending duplicate notifications

async function referralNotif(env) {
  const twoMinutesAgo = new Date(Date.now() - 120000).toISOString();

  // Recent referral_points inserts (last 2 minutes)
  const recent = await sbGet(
    `referral_points?select=id,referral_code,user_uid&created_at=gte.${twoMinutesAgo}&order=created_at.asc`,
    env
  );
  if (!recent.length) return;

  for (const row of recent) {
    const kvKey = `notified:${row.id}`;

    // Skip if already notified (KV dedup)
    const already = await env.NOTIFIED.get(kvKey);
    if (already) continue;

    // Mark as notified first (prevents race condition on retry)
    await env.NOTIFIED.put(kvKey, '1', { expirationTtl: 86400 }); // expires in 24h

    const { referral_code } = row;

    // Find referrer's user_uid by referral_code, then their telegram_id (two-step, service key)
    const referrerVotes = await sbGet(
      `peace_votes?select=user_uid&referral_code=eq.${encodeURIComponent(referral_code)}&limit=1`,
      env
    );
    const referrerUid = referrerVotes[0]?.user_uid;
    if (!referrerUid) continue;
    const tgRows = await sbGet(
      `user_telegram?select=telegram_id&user_uid=eq.${encodeURIComponent(referrerUid)}&limit=1`,
      env, true
    );
    const referrerTgId = tgRows[0]?.telegram_id;
    if (!referrerTgId) continue;

    // Count total referrals for this code
    const all = await sbGet(
      `referral_points?select=id&referral_code=eq.${encodeURIComponent(referral_code)}`,
      env
    );
    const total = all.length;

    await tgSend(referrerTgId,
      `🎉 <b>A new dove joined your flock!</b>\n\n` +
      `Someone accepted your invitation to NAVA PEACE.\n` +
      `You earned a Peace Dove 🕊️\n\n` +
      `Your total referrals: <b>${total}</b>`,
      env,
      {
        reply_markup: {
          inline_keyboard: [[
            { text: '🕊️ See My Doves', web_app: { url: `${APP_URL}/profile.html` } }
          ]]
        }
      }
    );
  }
}

// ── BOT 3 — Admin Hourly Alert ────────────────────────────────────────────────

async function adminAlert(env) {
  const TODAY = todayUTC();

  // Votes in last hour
  const recentVotes = await sbGet(
    `peace_votes?select=user_uid&created_at=gte.${hoursAgo(1)}`,
    env
  );
  const recentCount = recentVotes.length;

  // Silence if no activity
  if (recentCount === 0) return;

  // Votes today
  const todayVotes = await sbGet(
    `peace_votes?select=user_uid&created_at=gte.${TODAY}T00:00:00Z`,
    env
  );

  // Total distinct members
  const allVotes  = await sbGet('peace_votes?select=user_uid', env);
  const totalMembers = new Set(allVotes.map(v => v.user_uid)).size;

  // New referrals today
  const todayRefs = await sbGet(
    `referral_points?select=id&created_at=gte.${TODAY}T00:00:00Z`,
    env
  );

  // Spike flag
  const spike = recentCount >= 20 ? '🚀 SPIKE — ' : '';

  await tgSend(ADMIN_ID,
    `${spike}📊 <b>NAVA PEACE · ${bkkTime()} BKK</b>\n\n` +
    `• Last hour: <b>+${recentCount} votes</b>\n` +
    `• Today total: <b>${todayVotes.length} votes</b>\n` +
    `• New referrals today: <b>${todayRefs.length}</b>\n` +
    `• Total members: <b>${totalMembers}</b>`,
    env
  );
}

// ── BOT 4 — Group Welcome ─────────────────────────────────────────────────────
// Triggered by Telegram webhook when a new member joins the community group.

async function handleGroupWelcome(update, env) {
  const members = update.message?.new_chat_members;
  if (!members?.length) return;

  const chatId  = update.message.chat.id;
  const msgId   = update.message.message_id;

  for (const member of members) {
    if (member.is_bot) continue;

    const name = member.first_name || 'friend';

    await tgSend(chatId,
      `🕊️ Welcome <b>${name}</b> to NAVA PEACE!\n\n` +
      `Every day, thousands of people make one simple commitment:\n` +
      `<i>"Today, I commit to peace — for everyone, everywhere."</i>\n\n` +
      `To join the app, you need an <b>invitation code</b>.\n` +
      `Just introduce yourself here — a member will DM you one 🤝`,
      env,
      {
        reply_to_message_id: msgId,
        reply_markup: {
          inline_keyboard: [[
            { text: '🕊️ Learn more', url: `${APP_URL}/about.html` }
          ]]
        }
      }
    );
  }
}

// ── Main Handler ──────────────────────────────────────────────────────────────

export default {

  // Cron triggers
  async scheduled(event, env, ctx) {
    if (event.cron === '* * * * *')  ctx.waitUntil(referralNotif(env));
    if (event.cron === '0 17 * * *') ctx.waitUntil(dailyReminder(env));
    if (event.cron === '0 * * * *')  ctx.waitUntil(adminAlert(env));
  },

  // HTTP endpoints
  async fetch(request, env) {
    const { pathname } = new URL(request.url);

    // ── Health check ───────────────────────────────────────────
    if (pathname === '/health')
      return new Response('NAVA PEACE Bots — OK 🕊️', { status: 200 });

    // ── Telegram webhook (group events) ────────────────────────
    if (pathname === '/telegram' && request.method === 'POST') {
      // Verify secret header from Telegram
      const secret = request.headers.get('X-Telegram-Bot-Api-Secret-Token');
      if (secret !== env.WEBHOOK_SECRET) {
        return new Response('Unauthorized', { status: 401 });
      }
      try {
        const update = await request.json();
        await handleGroupWelcome(update, env);
      } catch (e) {
        console.error('Webhook error', e);
      }
      return new Response('OK');
    }

    return new Response('Not Found', { status: 404 });
  },
};
