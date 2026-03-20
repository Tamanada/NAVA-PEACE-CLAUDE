// Supabase Management API Proxy — Edge Function
// Proxies /v1/projects/{ref}/usage to bypass browser CORS restrictions.
// The PAT is sent from the admin panel and forwarded server-side.
//
// Deploy:
//   supabase functions deploy supabase-usage-proxy --no-verify-jwt

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-sb-pat',
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS });
  }

  // Expect PAT in custom header x-sb-pat
  const pat = req.headers.get('x-sb-pat');
  if (!pat) {
    return json({ error: 'Missing x-sb-pat header' }, 400);
  }

  // Extract project ref from URL: /supabase-usage-proxy?ref=xxxx
  const url = new URL(req.url);
  const ref = url.searchParams.get('ref');
  if (!ref) {
    return json({ error: 'Missing ref query param' }, 400);
  }

  try {
    const res = await fetch(`https://api.supabase.com/v1/projects/${ref}/usage`, {
      headers: {
        'Authorization': `Bearer ${pat}`,
        'Content-Type': 'application/json',
      },
    });

    const data = await res.json();
    return json(data, res.status);
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});
