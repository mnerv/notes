import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

const env = {
  MODE:           process.env.NODE_ENV,
  APP_NAME:       'Notes',
  VERSION:        process.env.npm_package_version,
  AUTHOR:         process.env.npm_package_author_name,
  DESCRIPTION:    process.env.npm_package_description,
  HOMEPAGE:       process.env.npm_package_homepage,
  COMMIT_HASH:    process.env.GITHUB_SHA || 'development',
  BUILD_DATE:     new Date().toISOString()
}

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
  define: {
    __VITE_ENV__: JSON.stringify(env)
  }
})
