#!/usr/bin/env bash
# NovaMatter one-time build patch: ensure full-resolution NovaLens ribbon artwork.
set -euo pipefail
test -f src/app/page.tsx
mkdir -p public/brand
asset="public/brand/novalens-crisp-v4.avif"
curl -fsSL --retry 3 "https://raw.githubusercontent.com/solbosio13-crypto/novamatter-media/5b490593777ee519967d6ca77a75f94a160014ce/brand/novalens-crisp-v4.avif" -o "$asset"
printf '%s  %s\n' "d011c8f01fb3208273dd5b9a5603838afec4fedad2bb29f726f92ee13dd7a63f" "$asset" | sha256sum -c -
node <<'JS'
const fs = require('node:fs');
const oldLogo = '/brand/novalens-green-final.webp';
const newLogo = '/brand/novalens-crisp-v4.avif';
let changed = 0;
for (const file of ['src/app/page.tsx','src/app/products/page.tsx','src/app/novalens/page.tsx']) {
  let content = fs.readFileSync(file,'utf8');
  const count = content.split(oldLogo).length - 1;
  if (count === 0) throw new Error('Unexpected NovaLens logo references in '+file);
  content = content.replaceAll(oldLogo,newLogo);
  changed += count;
  if (file === 'src/app/page.tsx') {
    const before = '                      width={236}\n                      height={236}\n                      src={';
    const after = '                      width={720}\n                      height={720}\n                      quality={95}\n                      unoptimized={product.accent === "lens"}\n                      sizes="(max-width: 640px) 220px, 260px"\n                      src={';
    if (!content.includes(before)) throw new Error('Unexpected homepage image component: check reviewed version');
    content = content.replace(before,after);
  }
  fs.writeFileSync(file,content);
}
if (changed !== 4) throw new Error('Unexpected changed logo reference count '+changed);
if (fs.existsSync('public/brand/novalens-green-final.webp')) fs.unlinkSync('public/brand/novalens-green-final.webp');
console.log('Applied verified NovaLens v4 branding patch to '+changed+' source references');
JS