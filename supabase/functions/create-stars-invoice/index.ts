// ── NAVA PEACE · Edge Function: create-stars-invoice ──────────────────────
// Generates a Telegram Stars invoice link for NFT purchases.
//
// POST body:
//   tier_code   : string  — e.g. "PEACE_GARDENER"
//   is_bundle   : boolean
//   user_uid    : string  — nava_peace_uid from localStorage
//   tg_user_id  : number  — Telegram user ID
//   stars_price : number  — amount in Stars (integer)
//   tier_name   : string  — e.g. "PEACE GARDENER"
//   multiplier  : number  — e.g. 2
//   items_count : number  — for bundles
//
// Required env vars:
//   TELEGRAM_BOT_TOKEN

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';

const BOT_TOKEN    = Deno.env.get('TELEGRAM_BOT_TOKEN')!;
const TELEGRAM_API = `https://api.telegram.org/bot${BOT_TOKEN}`;

const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, apikey, Authorization',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: CORS });
  }

  try {
    const {
      tier_code, is_bundle, user_uid, tg_user_id,
      stars_price, tier_name, multiplier, items_count,
    } = await req.json();

    if (!tier_code || !stars_price || !tier_name) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { ...CORS, 'Content-Type': 'application/json' } }
      );
    }

    // Build payload — stored in the invoice, returned on successful_payment
    const payload = JSON.stringify({
      user_uid,
      tg_user_id,
      tier_code,
      is_bundle: !!is_bundle,
    });

    // Build description
    const desc = is_bundle && items_count > 1
      ? `Bundle: ${items_count} Peace Cards · up to ×${multiplier} Mining Multiplier`
      : `Peace Card NFT · ×${multiplier} Mining Multiplier`;

    // Call Telegram Bot API createInvoiceLink
    const resp = await fetch(`${TELEGRAM_API}/createInvoiceLink`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        title:       `NAVA PEACE — ${tier_name}`,
        description: desc,
        payload,
        currency:    'XTR', // Telegram Stars
        prices:      [{ label: tier_name, amount: Math.round(stars_price) }],
      }),
    });

    const data = await resp.json();

    if (!data.ok) {
      console.error('Telegram API error:', data);
      return new Response(
        JSON.stringify({ error: data.description || 'Telegram API error' }),
        { status: 502, headers: { ...CORS, 'Content-Type': 'application/json' } }
      );
    }

    return new Response(
      JSON.stringify({ invoice_link: data.result }),
      { status: 200, headers: { ...CORS, 'Content-Type': 'application/json' } }
    );

  } catch (e) {
    console.error('create-stars-invoice error:', e);
    return new Response(
      JSON.stringify({ error: 'Internal error' }),
      { status: 500, headers: { ...CORS, 'Content-Type': 'application/json' } }
    );
  }
});
