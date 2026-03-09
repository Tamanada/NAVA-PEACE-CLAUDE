// Printify API Proxy — Supabase Edge Function
// Keeps PRINTIFY_API_KEY server-side, handles CORS for browser calls.
//
// Deploy:
//   supabase secrets set PRINTIFY_API_KEY=your_key PRINTIFY_SHOP_ID=your_shop_id
//   supabase functions deploy printify-proxy --no-verify-jwt

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const PRINTIFY_API_KEY = Deno.env.get('PRINTIFY_API_KEY') ?? '';
const PRINTIFY_SHOP_ID = Deno.env.get('PRINTIFY_SHOP_ID') ?? '';
const PRINTIFY_BASE    = 'https://api.printify.com/v1';

const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  // Preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS });
  }

  if (!PRINTIFY_API_KEY || !PRINTIFY_SHOP_ID) {
    return json({ error: 'Missing PRINTIFY_API_KEY or PRINTIFY_SHOP_ID secrets.' }, 500);
  }

  const url    = new URL(req.url);
  const action = url.searchParams.get('action') ?? 'products';

  try {
    // ── List products (paginated) ──────────────────────────────────
    if (action === 'products') {
      const page  = url.searchParams.get('page')  ?? '1';
      const limit = url.searchParams.get('limit') ?? '20';

      const res  = await printifyFetch(
        `/shops/${PRINTIFY_SHOP_ID}/products.json?page=${page}&limit=${limit}`
      );
      const data = await res.json();

      // Slim down payload: only fields needed by market.html
      const slim = {
        current_page: data.current_page,
        last_page:    data.last_page,
        data: (data.data ?? []).map(slimProduct),
      };
      return json(slim);
    }

    // ── Single product ─────────────────────────────────────────────
    if (action === 'product') {
      const id  = url.searchParams.get('id');
      if (!id) return json({ error: 'Missing id param' }, 400);

      const res  = await printifyFetch(`/shops/${PRINTIFY_SHOP_ID}/products/${id}.json`);
      const data = await res.json();
      return json(slimProduct(data));
    }

    return json({ error: 'Unknown action' }, 400);

  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return json({ error: msg }, 500);
  }
});

// ── Helpers ────────────────────────────────────────────────────────────────

async function printifyFetch(path: string): Promise<Response> {
  return fetch(`${PRINTIFY_BASE}${path}`, {
    headers: {
      'Authorization': `Bearer ${PRINTIFY_API_KEY}`,
      'Content-Type':  'application/json',
    },
  });
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
}

// Keep only what the storefront needs
function slimProduct(p: Record<string, unknown>) {
  const variants  = (p.variants  as Array<Record<string, unknown>>) ?? [];
  const images    = (p.images    as Array<Record<string, unknown>>) ?? [];
  const external  = (p.external  as Record<string, unknown>)        ?? {};

  // Cheapest enabled variant price (in cents → divide by 100 in JS)
  const enabledPrices = variants
    .filter((v) => v.is_enabled)
    .map((v)    => Number(v.price))
    .filter((n) => n > 0);
  const minPrice = enabledPrices.length ? Math.min(...enabledPrices) : 0;

  // First front image, fallback to first image
  const frontImg = images.find((i) => i.position === 'front') ?? images[0] ?? {};

  return {
    id:         p.id,
    title:      p.title,
    image:      frontImg.src ?? null,
    min_price:  minPrice,          // cents
    currency:   'USD',
    external:   external,          // { id, handle } if published
    tags:       (p.tags as string[]) ?? [],
  };
}
