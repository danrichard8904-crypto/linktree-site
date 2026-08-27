import { defineConfig } from 'astro/config';

// Dual-target during the Cloudflare migration.
// Cloudflare Pages sets CF_PAGES=1 in every build; GitHub Actions does not.
// Serving root on Cloudflare, /linktree-site on the old github.io URL, keeps
// BOTH sites working until the DNS/link cutover is done. Delete the ternary
// (keep the CF branch) once github.io is retired.
const onCloudflare = process.env.CF_PAGES === '1';

export default defineConfig({
  site: onCloudflare
    ? 'https://reppstory.pages.dev'
    : 'https://danrichard8904-crypto.github.io',
  base: onCloudflare ? '/' : '/linktree-site',
});
