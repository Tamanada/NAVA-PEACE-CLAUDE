# -*- coding: utf-8 -*-
"""
NAVA PEACE theme codemod.

Wraps hardcoded style literals in CSS custom properties whose FALLBACK is the
original literal:  #3AACDF  ->  var(--nv-b-bm,#3AACDF)
So with no theme stylesheet (or the default Sky theme) every page renders
exactly as before. Other themes only have to define the --nv-* tokens.

Modes:
  inventory <dir>   print token usage + unclassified literals, change nothing
  apply <dir>       rewrite files in place
  check <dir> [ref] prove reversibility: detokenize(current) == version at git ref
                    (default HEAD; after committing, pass the pre-theme commit)
"""
import re, sys, os, io, colorsys, collections, subprocess

HTML = ['about.html', 'index.html', 'map.html', 'market.html', 'merch.html', 'peace.html',
        'policy.html', 'profile.html', 'shop.html', 'splash.html', 'stats.html', 'wallet.html']
JS = ['discovery.js', 'lang.js', 'nava-audio.js']

usage = collections.Counter()
unclassified = collections.Counter()

# ---------------------------------------------------------------- colour families
def family(r, g, b):
    mx, mn = max(r, g, b), min(r, g, b)
    h, l, s = colorsys.rgb_to_hls(r / 255.0, g / 255.0, b / 255.0)
    hue = h * 360
    if l >= 0.85 and mx - mn <= 30:
        return 'w'
    if mx - mn <= 14:
        return None                      # neutral greys / blacks: left untouched
    if 170 <= hue <= 250:
        if l >= 0.62: return 'bl'
        if l >= 0.45: return 'bm'
        if l >= 0.20: return 'bd'
        return 'nv'
    if 20 <= hue < 65:  return 'gd'
    if 65 <= hue < 170: return 'gr'
    if hue >= 330 or hue < 20: return 'rd'
    return None

def hex_rgb(hx):
    hx = hx.lstrip('#')
    if len(hx) == 3:
        hx = ''.join(c * 2 for c in hx)
    return int(hx[0:2], 16), int(hx[2:4], 16), int(hx[4:6], 16)

HEX = r'#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{3})(?![0-9a-fA-F])'
RGBA = r'rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*([0-9.]+%?)\s*)?\)'
WHITE = r'(?<![-\w#])white(?![-\w(])'
COLOR_RE = re.compile('(%s)|(%s)|(%s)' % (HEX, RGBA, WHITE))

CTX = {
    'color': 't', 'fill': 't', 'stroke': 't', 'caret-color': 't', '-webkit-text-fill-color': 't',
    'background': 'b', 'background-color': 'b', 'background-image': 'b',
    'box-shadow': 's', 'text-shadow': 's', 'filter': 's', '-webkit-filter': 's',
}
def ctx_of(prop):
    p = prop.lower()
    if p in CTX: return CTX[p]
    if p.startswith('border') and 'radius' not in p and 'collapse' not in p and 'spacing' not in p: return 'l'
    if p.startswith('outline'): return 'l'
    return None

IG_SIGNATURE = re.compile(r'#dc2743|#bc1888|#cc2366', re.I)   # Instagram brand gradient: never themed
DECL = re.compile(r'(?P<pre>(?:^|[;{\s"\'`]))(?P<prop>-?-?[a-zA-Z][\w-]*)(?P<sep>\s*:\s*)(?P<val>[^;{}]*)')

def first_opaque_family(val):
    """family of the first opaque (hex) colour in a background value, ignoring radial gradients"""
    v = re.sub(r'radial-gradient\([^;]*', '', val)
    m = re.search(HEX, v)
    if not m: return None
    return family(*hex_rgb(m.group(0)))

def tok(name):
    usage[name] += 1
    return '--nv-' + name

def recolor(val, ctx, on_fam, clip_text):
    """replace colour literals inside one declaration value"""
    if 'var(--nv-' in val or IG_SIGNATURE.search(val):
        return val
    # locate gradient spans so stops can be classed
    spans = []
    for m in re.finditer(r'(radial|linear|conic)-gradient\(', val):
        depth, i = 1, m.end()
        while i < len(val) and depth:
            depth += val[i] == '('
            depth -= val[i] == ')'
            i += 1
        spans.append((m.start(), i, m.group(1)))
    grad_first = {}
    for a, b, kind in spans:
        if kind == 'linear':
            m = re.search(HEX, val[a:b])
            if m: grad_first[(a, b)] = (family(*hex_rgb(m.group(0))), a + m.start())

    def span_at(pos):
        for a, b, kind in spans:
            if a <= pos < b: return (a, b, kind)
        return None

    def repl(m):
        txt = m.group(0)
        sp = span_at(m.start())
        c = ctx
        if clip_text and c == 'b': c = 't'
        is_hex = txt.startswith('#')
        is_white_name = txt.lower() == 'white'
        if is_hex or is_white_name:
            fam = 'w' if is_white_name else family(*hex_rgb(txt))
            if fam is None:
                unclassified[txt.lower() + ' [' + (c or '?') + ']'] += 1
                return txt
            if sp and sp[2] == 'radial' and c == 'b':
                return 'var(%s,%s)' % (tok('g-' + fam), txt)
            if sp and sp[2] == 'linear' and c in ('b', 't') and (sp[0], sp[1]) in grad_first:
                ffam, fpos = grad_first[(sp[0], sp[1])]
                if ffam:
                    return 'var(%s,%s)' % (tok('%s-%s%s' % (c, ffam, '' if m.start() == fpos else '2')), txt)
            if c == 't' and fam == 'w' and on_fam and on_fam != 'w':
                return 'var(%s,%s)' % (tok('on-' + on_fam), txt)
            return 'var(%s,%s)' % (tok('%s-%s' % (c, fam)), txt)
        # rgb()/rgba()
        r, g, b, a = int(m.group(3)), int(m.group(4)), int(m.group(5)), m.group(6)
        fam = family(r, g, b)
        if fam is None:
            if (r, g, b) != (0, 0, 0):
                unclassified['rgb(%d,%d,%d) [%s]' % (r, g, b, c or '?')] += 1
            return txt
        cc = c
        if sp and sp[2] == 'radial' and c == 'b': cc = 's'      # translucent radial = glow
        if cc == 't' and fam == 'w' and on_fam and on_fam != 'w':
            name = 'on-%s-rgb' % on_fam
        else:
            name = '%s-%s-rgb' % (cc, fam)
        inner = re.match(r'(rgba?\(\s*)(\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3})(.*)$', txt, re.S)
        return '%svar(%s,%s)%s' % (inner.group(1), tok(name), inner.group(2), inner.group(3))

    return COLOR_RE.sub(repl, val)

PX = re.compile(r'(?<![\w.#-])(\d+(?:\.\d+)?)px')

def transform_block(body):
    """body = text of one declaration list (CSS rule body or style attribute)"""
    decls = list(DECL.finditer(body))
    if not decls: return body
    props = {}
    for d in decls:
        props.setdefault(d.group('prop').lower(), d.group('val'))
    on_fam = None
    for p in ('background', 'background-color', 'background-image'):
        if p in props:
            on_fam = first_opaque_family(props[p])
            if on_fam: break
    clip_text = any('text' in props.get(p, '') for p in ('-webkit-background-clip', 'background-clip'))
    dims = set()
    for p in ('width', 'height'):
        m = re.match(r'\s*(\d+(?:\.\d+)?)px', props.get(p, ''))
        if m: dims.add(float(m.group(1)))

    def fix(d):
        prop, val = d.group('prop'), d.group('val')
        p = prop.lower()
        new = val
        if p.startswith('--'):
            return d.group(0)                       # custom property definitions: handled in theme.css
        c = ctx_of(p)
        if c:
            new = recolor(new, c, on_fam, clip_text)
            if c == 's' and 'var(--nv-inv' not in new:
                new, n = re.subn(r'brightness\(0\)\s+invert\(1\)', lambda m: m.group(0)[:-2] + 'var(%s,1))' % tok('inv'), new)
        elif p == 'font-family':
            if 'asalization' in new and 'var(--nv-' not in new:
                lead = re.match(r'\s*', new).group(0)
                core = new[len(lead):].rstrip()
                trail = new[len(lead) + len(core):]
                imp = ''
                mi = re.search(r'\s*!important$', core)
                if mi:
                    imp, core = mi.group(0), core[:mi.start()]
                new = '%svar(%s,%s)%s%s' % (lead, tok('font'), core, imp, trail)
        elif p == 'border-radius' or (p.startswith('border-') and p.endswith('-radius')):
            if 'var(--nv-' not in new:
                def rr(m):
                    v = float(m.group(1))
                    if v >= 100 or v == 0: return m.group(0)
                    if len(dims) == 1 and v * 2 >= min(dims): return m.group(0)   # px circle
                    return 'calc(%spx * var(%s,1))' % (m.group(1), tok('r'))
                new = PX.sub(rr, new)
        elif p == 'letter-spacing':
            if 'var(--nv-' not in new:
                new = PX.sub(lambda m: m.group(0) if float(m.group(1)) == 0 else 'calc(%spx * var(%s,1))' % (m.group(1), tok('ls')), new)
        return d.group('pre') + prop + d.group('sep') + new

    return DECL.sub(fix, body)

# ---------------------------------------------------------------- regions
STYLE_BLOCK = re.compile(r'(<style[^>]*>)(.*?)(</style>)', re.S | re.I)
RULE_BODY = re.compile(r'\{([^{}]*)\}')
STYLE_ATTR = re.compile(r'(style\s*=\s*)(\\?")((?:(?!\2).)*?)(\2)', re.S)
STYLE_ATTR_SQ = re.compile(r"(style\s*=\s*)(\\?')((?:(?!\2)[^\n])*?)(\2)")
CSSISH = re.compile(r'(?:^|[;\s])(?:color|background(?:-color)?|border(?:-[a-z]+)*|box-shadow|text-shadow|font-family|letter-spacing)\s*:\s*[^;]', re.I)
JS_STR = re.compile(r"'(?:[^'\\\n]|\\.)*'|\"(?:[^\"\\\n]|\\.)*\"")
STYLE_SET = re.compile(r"(\.style\.)(color|background|backgroundColor|borderColor|border|borderTop|borderBottom|boxShadow|textShadow)(\s*=\s*)(['\"])((?:(?!\4)[^\n\\])*)(\4)")
JS_PROP = {'color': 'color', 'background': 'background', 'backgroundColor': 'background-color', 'borderColor': 'border-color',
           'border': 'border', 'borderTop': 'border-top', 'borderBottom': 'border-bottom', 'boxShadow': 'box-shadow', 'textShadow': 'text-shadow'}

def css_text(css):
    return RULE_BODY.sub(lambda m: '{' + transform_block(m.group(1)) + '}', css)

def js_text(js):
    def str_fix(m):
        s = m.group(0)
        q, inner = s[0], s[1:-1]
        if 'style=' in inner or not CSSISH.search(inner):
            return s
        return q + transform_block(inner) + q
    js = JS_STR.sub(str_fix, js)
    def set_fix(m):
        val = transform_block(JS_PROP[m.group(2)] + ':' + m.group(5))
        return m.group(1) + m.group(2) + m.group(3) + m.group(4) + val.split(':', 1)[1] + m.group(6)
    return STYLE_SET.sub(set_fix, js)

def attrs(text):
    text = STYLE_ATTR.sub(lambda m: m.group(1) + m.group(2) + transform_block(m.group(3)) + m.group(4), text)
    return STYLE_ATTR_SQ.sub(lambda m: m.group(1) + m.group(2) + transform_block(m.group(3)) + m.group(4), text)

SCRIPT_BLOCK = re.compile(r'(<script(?![^>]*\bsrc=)[^>]*>)(.*?)(</script>)', re.S | re.I)

def html_text(text):
    text = STYLE_BLOCK.sub(lambda m: m.group(1) + css_text(m.group(2)) + m.group(3), text)
    text = attrs(text)
    text = SCRIPT_BLOCK.sub(lambda m: m.group(1) + js_text(m.group(2)) + m.group(3), text)
    return text

def js_file(text):
    return js_text(attrs(text))

# ---------------------------------------------------------------- reverse
REV_CALC = re.compile(r'calc\(([0-9.]+px) \* var\(--nv-(?:r|ls),1\)\)')
REV_VAR = re.compile(r'var\(--nv-[a-z0-9-]+,([^()]*)\)')
def detokenize(text):
    text = REV_CALC.sub(r'\1', text)
    return REV_VAR.sub(r'\1', text)

def read(p):
    with io.open(p, encoding='utf-8', newline='') as f: return f.read()
def write(p, s):
    with io.open(p, 'w', encoding='utf-8', newline='') as f: f.write(s)

def main():
    mode, d = sys.argv[1], sys.argv[2]
    ref = sys.argv[3] if len(sys.argv) > 3 else 'HEAD'
    bad = 0
    for name in HTML + JS:
        p = os.path.join(d, name)
        if not os.path.exists(p):
            print('missing', name); continue
        src = read(p)
        if mode == 'check':
            head = subprocess.run(['git', '-C', d, 'show', ref + ':' + name], capture_output=True).stdout.decode('utf-8')
            cur = detokenize(src)
            # hand-added theme hooks are allowed only on lines carrying the marker
            import difflib
            a = head.splitlines(); b = cur.splitlines()
            ok = True
            for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
                if tag == 'equal': continue
                if tag == 'delete' or not all('nv-theme-hook' in l for l in b[j1:j2]):
                    ok = False
                    print('   unexpected change near line', j1 + 1, repr(b[j1:j2][:1])[:140])
            print('%-14s %s' % (name, 'reversible' if ok else 'DIFFERS'))
            bad += not ok
            continue
        out = html_text(src) if name.endswith('.html') else js_file(src)
        if detokenize(out) != src:
            print('!! not reversible:', name); bad += 1
        if mode == 'apply' and out != src:
            write(p, out)
        print('%-14s %5d replacements' % (name, len(re.findall(r'var\(--nv-', out)) - len(re.findall(r'var\(--nv-', src))))
    if mode != 'check':
        print('\n== tokens ==')
        for k, v in sorted(usage.items()):
            print('  %-16s %d' % (k, v))
        print('\n== unclassified (left as is) ==')
        for k, v in unclassified.most_common(60):
            print('  %-34s %d' % (k, v))
    sys.exit(1 if bad else 0)

main()
