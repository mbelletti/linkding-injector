# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a browser extension that injects linkding bookmark search results into search engine pages (Google, DuckDuckGo, Brave, Kagi, Qwant, SearX). The extension is built as a WebExtension using Manifest v2 with Svelte components and Rollup bundling.

## Build System

### Development Commands
- `npm run dev` - Development build with watch mode (unpackaged, unminified for debugging)
- `npm run build` - Production build (transpiled, minified via Rollup + SCSS compilation)
- `./build.sh` - Full build script including web-ext packaging for Firefox (uses MV2 `manifest.json`)
- `./build.ps1` - Windows PowerShell equivalent of build script
- `./build-chrome.sh` - Chrome (Manifest V3) build; stages `dist-chrome/` using `manifest.chrome.json` and produces `linkding-injector-chrome.zip`

### Build Process
The build system uses Rollup to create three separate bundles:
- `build/bundle.js` - Options page (from `src/index.js`)
- `build/background.js` - Background script (from `src/background.js`) 
- `build/searchInjection.js` - Content script (from `src/searchInjection.js`)

SCSS is compiled separately via `sass` to `build/searchInjection.css`.

## Architecture

### Core Components
- **Background Script** (`src/background.js`): Handles communication between content script and linkding API
- **Content Script** (`src/searchInjection.js`): Injects bookmark results into search engine sidebars
- **Options Page** (`src/options.svelte`): Svelte component for extension configuration
- **Configuration** (`src/configuration.js`): Manages extension settings storage
- **Linkding API** (`src/linkding.js`): Interface to linkding bookmark service

### Extension Structure
- **Two manifests in this branch**: `manifest.json` (Manifest V2, Firefox) and `manifest.chrome.json` (Manifest V3, Chrome). They differ only in MV3-specific keys: `manifest_version`, background (service worker vs. persistent scripts), `permissions`/`host_permissions` split, and `web_accessible_resources` format. The Chrome build copies `manifest.chrome.json` in as `manifest.json`.
- **Content Scripts**: Inject into multiple search engines with specific URL patterns
- **Background Script**: Persistent background page for API communication
- **Options UI**: Standalone configuration page
- **Web Accessible Resources**: Icons and assets

### Search Engine Integration
The extension detects search engines by hostname/URL patterns and uses specific CSS selectors for sidebar injection:
- Google: `#rhs` (with fallback container creation)
- DuckDuckGo: `section[data-area=sidebar]`
- Brave: `aside.sidebar` (with 1600ms injection delay)
- Kagi: `.right-content-box > ._0_right_sidebar`
- Qwant: `.is-sidebar` (with MutationObserver for async loading)
- SearX: `#sidebar`

### Theme System
Supports automatic theme detection plus manual light/dark theme overrides per search engine.

## Development Notes

- Uses ES6 modules with Rollup bundling
- Svelte components for UI (options page)
- Cross-browser compatibility (Chrome/Firefox) via browser API detection
- HTML sanitization for security (`escapeHTML` function)
- Extension communicates via runtime.connect ports between content script and background

## Testing

No automated test framework is configured. Manual testing involves loading the unpacked extension in browser developer mode after running `npm run build`.