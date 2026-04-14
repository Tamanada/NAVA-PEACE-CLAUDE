// ── NAVA PEACE · Edge Function: telegram-webhook ─────────────────────────────
// Handles incoming Telegram bot updates.
//
// Commands handled:
//   /adminpaneladmin  – sends the admin panel link (only to the admin)
//
// Payment events:
//   pre_checkout_query  – MUST be answered within 10s or payment is cancelled
//   successful_payment  – grants NFT badge in Supabase
//
// Required env vars:
//   TELEGRAM_BOT_TOKEN       – from BotFather
//   ADMIN_TELEGRAM_ID        – your Telegram user ID (numeric)
//   SUPABASE_URL             – your Supabase project URL
//   SUPABASE_SERVICE_ROLE_KEY – service role key (bypasses RLS for badge grant)

import { serve }        from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const BOT_TOKEN    = Deno.env.get('TELEGRAM_BOT_TOKEN')!;
const ADMIN_TG_ID  = Deno.env.get('ADMIN_TELEGRAM_ID')!;
const ADMIN_URL    = 'https://main.shy-sky-0af1.pages.dev/admin';
const TG_API       = `https://api.telegram.org/bot${BOT_TOKEN}`;
const SB_URL       = Deno.env.get('SUPABASE_URL')!;
const SB_KEY       = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

// ── helpers ──────────────────────────────────────────────────────────────────
async function sendMessage(chatId: number, text: string) {
  await fetch(`${TG_API}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ chat_id: chatId, text, parse_mode: 'HTML' }),
  });
}

async function answerPreCheckout(queryId: string, ok: boolean, errorMsg?: string) {
  await fetch(`${TG_API}/answerPreCheckoutQuery`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      pre_checkout_query_id: queryId,
      ok,
      ...(errorMsg ? { error_message: errorMsg } : {}),
    }),
  });
}

// ── grant NFT badge via Supabase service role ─────────────────────────────────
async function grantBadge(userUid: string, tierCode: string, isBundle: boolean) {
  if (!SB_URL || !SB_KEY) return;
  const sb = createClient(SB_URL, SB_KEY);

  // Determine which codes to grant
  const TIER_ORDER = [
    'PEACE_LOVER','PEACE_GARDENER','PEACE_GUARDIAN','PEACE_GUIDE',
    'PEACE_ILLUMINATOR','PEACE_LEGEND','ANGEL_OF_PEACE','PEACE_POWER',
  ];
  const targetIdx = TIER_ORDER.indexOf(tierCode);
  const codes: string[] = isBundle && targetIdx > 0
    ? TIER_ORDER.slice(1, targetIdx + 1)   // bundle: tiers 2..N
    : [tierCode];

  for (const code of codes) {
    await sb.from('user_badges').upsert(
      { user_uid: userUid, badge_code: code, payment_method: 'stars' },
      { onConflict: 'user_uid,badge_code' }
    );
  }

  // Log the purchase
  await sb.from('nft_pending_purchases').insert({
    user_uid: userUid,
    tier_code: tierCode,
    is_bundle: isBundle,
    wallet_addr: 'pending_claim',
    status: 'paid_stars',
    payment_method: 'stars',
    created_at: new Date().toISOString(),
  }).catch(() => {/* table may not exist yet */});
}

// ── main handler ──────────────────────────────────────────────────────────────
serve(async (req) => {
  if (req.method !== 'POST') return new Response('OK', { status: 200 });

  try {
    const update = await req.json();

    // ── pre_checkout_query — MUST respond within 10 seconds ──────────────────
    if (update.pre_checkout_query) {
      const pcq = update.pre_checkout_query;
      // Always approve — validation already done client-side
      await answerPreCheckout(pcq.id, true);
      return new Response('OK', { status: 200 });
    }

    // ── successful_payment ────────────────────────────────────────────────────
    const message = update.message;
    if (message?.successful_payment) {
      const sp      = message.successful_payment;
      const payload = JSON.parse(sp.invoice_payload || '{}');

      const userUid  = payload.user_uid  as string | undefined;
      const tierCode = payload.tier_code as string | undefined;
      const isBundle = payload.is_bundle as boolean | undefined;

      if (userUid && tierCode) {
        await grantBadge(userUid, tierCode, !!isBundle);
        await sendMessage(
          message.chat.id,
          `⭐ <b>Payment confirmed!</b>\n\nYour <b>${tierCode.replace(/_/g,' ')}</b> NFT has been added to your NAVA PEACE collection.\n\n🕊 Open the app to see your card.`
        );
      }
      return new Response('OK', { status: 200 });
    }

    // ── text commands ─────────────────────────────────────────────────────────
    if (message) {
      const chatId = message.chat?.id;
      const userId = message.from?.id;
      const text   = (message.text || '').trim();

      if (text === '/adminpaneladmin' || text.startsWith('/adminpaneladmin@')) {
        if (String(userId) !== String(ADMIN_TG_ID)) {
          await sendMessage(chatId, '⛔ Accès réservé à l\'administrateur.');
        } else {
          await sendMessage(chatId,
            `🔑 <b>Panel Admin NAVA PEACE</b>\n\n👉 <a href="${ADMIN_URL}">${ADMIN_URL}</a>`
          );
        }
      }
    }

    return new Response('OK', { status: 200 });

  } catch (e) {
    console.error('webhook error:', e);
    return new Response('Error', { status: 500 });
  }
});
