// ── NAVA PEACE · Edge Function: verify-ton-payment ───────────────────────────
// Checks the TON blockchain for an incoming USDT jetton payment to the
// treasury wallet, then auto-grants the NFT badge if confirmed.
//
// POST body:
//   purchase_id    : string  — ID from nft_pending_purchases
//   user_uid       : string
//   tier_code      : string  — e.g. "PEACE_GARDENER"
//   is_bundle      : boolean
//   wallet_addr    : string  — buyer's TON wallet address (raw or friendly)
//   expected_usdt  : number  — expected USDT amount (e.g. 5.0)
//
// Returns:
//   { confirmed: true,  tx_hash }  — payment found & badge granted
//   { confirmed: false, reason }   — not yet found or amount mismatch
//
// Required env vars:
//   SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY
//   TONAPI_KEY  (optional — get free key at tonapi.io, increases rate limit)

import { serve }        from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SB_URL       = Deno.env.get('SUPABASE_URL')!;
const SB_KEY       = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const TONAPI_KEY   = Deno.env.get('TONAPI_KEY') || '';

// USDT jetton master contract on TON mainnet
const USDT_MASTER  = 'EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs';

const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, apikey, Authorization',
};

// ── TON API helpers ───────────────────────────────────────────────────────────
async function getJettonTransfers(treasuryAddr: string, limit = 30) {
  const headers: Record<string, string> = { 'Accept': 'application/json' };
  if (TONAPI_KEY) headers['Authorization'] = `Bearer ${TONAPI_KEY}`;

  const url = `https://tonapi.io/v2/accounts/${encodeURIComponent(treasuryAddr)}`
            + `/jettons/transfers?limit=${limit}&direction=in`;
  const resp = await fetch(url, { headers });
  if (!resp.ok) throw new Error(`TON API error ${resp.status}`);
  return (await resp.json()).events as Array<{
    transaction_hash: string;
    timestamp: number;
    sender: { address: string };
    amount: string;       // nano-USDT (6 decimals)
    jetton: { address: string };
    comment?: string;
  }>;
}

// Normalize TON address for comparison (strip bounceable flag etc.)
function normalizeAddr(addr: string): string {
  return addr.replace(/[^A-Za-z0-9_-]/g, '').toLowerCase();
}

// ── badge grant (same as telegram-webhook) ────────────────────────────────────
async function grantBadge(
  sb: ReturnType<typeof createClient>,
  userUid: string, tierCode: string, isBundle: boolean
) {
  const TIER_ORDER = [
    'PEACE_LOVER','PEACE_GARDENER','PEACE_GUARDIAN','PEACE_GUIDE',
    'PEACE_ILLUMINATOR','PEACE_LEGEND','ANGEL_OF_PEACE','PEACE_POWER',
  ];
  const idx   = TIER_ORDER.indexOf(tierCode);
  const codes = isBundle && idx > 0
    ? TIER_ORDER.slice(1, idx + 1)
    : [tierCode];

  for (const code of codes) {
    await sb.from('user_badges').upsert(
      { user_uid: userUid, badge_code: code, payment_method: 'ton_usdt' },
      { onConflict: 'user_uid,badge_code' }
    );
  }
}

// ── main handler ──────────────────────────────────────────────────────────────
serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405, headers: CORS });

  const json = (body: object, status = 200) =>
    new Response(JSON.stringify(body), {
      status, headers: { ...CORS, 'Content-Type': 'application/json' }
    });

  try {
    const { purchase_id, user_uid, tier_code, is_bundle,
            wallet_addr, expected_usdt, treasury_addr } = await req.json();

    if (!purchase_id || !user_uid || !tier_code || !wallet_addr || !treasury_addr) {
      return json({ confirmed: false, reason: 'Missing required fields' }, 400);
    }

    const sb = createClient(SB_URL, SB_KEY);

    // Check if already confirmed (idempotent)
    const { data: existing } = await sb
      .from('nft_pending_purchases')
      .select('status')
      .eq('id', purchase_id)
      .maybeSingle();

    if (existing?.status === 'paid_ton') {
      return json({ confirmed: true, reason: 'already_confirmed' });
    }

    // Fetch recent incoming USDT transfers to treasury
    const transfers = await getJettonTransfers(treasury_addr, 50);

    // Look for matching transfer:
    // sender matches buyer wallet + amount matches + happened in last 30 minutes
    const cutoff      = Math.floor(Date.now() / 1000) - 1800; // 30 min window
    const expectedNano = Math.round(expected_usdt * 1_000_000); // USDT = 6 decimals
    const tolerance    = 10_000; // 0.01 USDT tolerance for rounding
    const normBuyer    = normalizeAddr(wallet_addr);

    const match = transfers.find(t => {
      if (t.jetton.address !== USDT_MASTER) return false;
      if (t.timestamp < cutoff) return false;
      const amount = parseInt(t.amount, 10);
      if (Math.abs(amount - expectedNano) > tolerance) return false;
      return normalizeAddr(t.sender.address) === normBuyer
          || normalizeAddr(t.sender.address).includes(normBuyer.slice(-12));
    });

    if (!match) {
      return json({ confirmed: false, reason: 'not_found_yet' });
    }

    // ── Payment confirmed! Grant badge ────────────────────────────────────
    await grantBadge(sb, user_uid, tier_code, !!is_bundle);

    // Update purchase record
    await sb.from('nft_pending_purchases')
      .update({ status: 'paid_ton', tx_hash: match.transaction_hash })
      .eq('id', purchase_id);

    return json({ confirmed: true, tx_hash: match.transaction_hash });

  } catch (e) {
    console.error('verify-ton-payment error:', e);
    return json({ confirmed: false, reason: 'server_error' }, 500);
  }
});
