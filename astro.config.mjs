import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  integrations: [tailwind()],
  markdown: {
    gfm: true,
    shikiConfig: {
      theme: 'github-light'
    }
  }
});
