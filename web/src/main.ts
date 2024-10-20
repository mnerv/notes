import './app.css'
import App from './App.svelte'

const APP_NAME    = __VITE_ENV__.APP_NAME
const VERSION     = __VITE_ENV__.VERSION
const COMMIT_HASH = __VITE_ENV__.COMMIT_HASH
const BUILD_DATE  = __VITE_ENV__.BUILD_DATE

console.log(`${APP_NAME} - v${VERSION}-${COMMIT_HASH.slice(0, 7)}
build date: ${BUILD_DATE}`.trim())

const app = new App({
  target: document.getElementById('app')!,
})

export default app
