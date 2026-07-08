# 4get Search Engine Support Specification

## Overview
This document specifies the requirements and implementation details for adding 4get search engine support to the linkding-injector browser extension.

### About 4get
- **Type**: Open-source proxy search engine and metasearch engine
- **Focus**: Privacy-oriented, lightweight, ad-free search experience
- **Self-hostable**: Can be deployed on any domain/subdomain
- **URL Pattern**: Typically uses `/web` endpoint for web searches
- **Search Parameter**: Uses `s` parameter for search terms (needs verification)
- **Target Instance**: http://192.168.2.36:8085/

## Implementation Requirements

### 1. Manifest Changes
**File**: `manifest.json`
**Location**: `content_scripts` array
**Addition**:
```json
{
  "matches": ["*://*/web", "*://*/web?*"],
  "css": ["build/searchInjection.css"],
  "js": ["build/searchInjection.js"]
}
```

### 2. Search Engine Detection
**File**: `src/searchInjection.js`
**Location**: Lines 22-36 (after qwant detection)
**Addition**:
```javascript
} else if (document.location.href.match(/http.?:\/\/.+\/web(\?|$)/)) {
  searchEngine = "4get";
```

### 3. Sidebar Selector
**File**: `src/searchInjection.js`
**Location**: Lines 39-46 (`sidebarSelectors` object)
**Addition**:
```javascript
"4get": "[SELECTOR_TBD]", // Requires DOM inspection of target instance
```
**Action Required**: Inspect http://192.168.2.36:8085/ DOM structure to determine injection point

### 4. Theme Configuration
**File**: `src/searchInjection.js`
**Location**: Lines 85-92 (`themes` object)
**Addition**:
```javascript
4get: m.config.theme4get,
```

### 5. Search Term Extraction
**File**: `src/searchInjection.js`
**Location**: Lines 199-204 (after searx handling)
**Addition**:
```javascript
if (searchEngine == "searx") {
  searchTerm = escapeHTML(document.querySelector("input#q").value);
} else if (searchEngine == "4get") {
  searchTerm = escapeHTML(urlParams.get("s")); // Verify parameter name
}
```

### 6. Configuration Schema Updates
**File**: `src/configuration.js`
**Required Changes**:
- Add `theme4get: "auto"` to default configuration object
- Add validation for theme4get in configuration validation logic
- Ensure theme4get is included in configuration save/load operations

### 7. Options UI Updates
**File**: `src/options.svelte`
**Required Changes**:
- Add 4get theme selector dropdown (auto/light/dark options)
- Include 4get in supported search engines list/documentation
- Add 4get-specific configuration options if needed

### 8. Styling Updates
**Files**: `scss/injectionBox.scss`, `scss/bookmarks.scss`
**Required Changes**:
- Add `.4get` CSS class selectors
- Ensure proper theme inheritance for 4get instances
- Test visual consistency with existing search engines

## Technical Considerations

### Domain Pattern Matching
- **Challenge**: 4get can be self-hosted on any domain
- **Solution**: Use broad `/web` endpoint pattern matching
- **Risk**: May match unintended sites using `/web` paths
- **Mitigation**: Combine URL patterns with DOM structure validation

### Search Parameter Detection
- **Primary**: URL parameter `s` (common in 4get)
- **Fallback**: DOM input field query if URL parsing fails
- **Verification Needed**: Test with target instance to confirm parameter naming

### Injection Timing
- **Assessment Required**: Determine if 4get requires:
  - Timing delays (like Brave Search - 1600ms)
  - Async loading detection (like Qwant - MutationObserver)
  - Immediate injection (like Google/DuckDuckGo)

### Special Handling Patterns
If special handling is required, follow existing patterns:

**Timing Delay Pattern** (like Brave):
```javascript
if (searchEngine == "4get") {
  setTimeout(function () {
    port.postMessage({ searchTerm: searchTerm });
  }, [DELAY_MS]);
}
```

**Async Loading Pattern** (like Qwant):
```javascript
if (searchEngine == "4get") {
  const observer = new MutationObserver((mutations, observer) => {
    if (document.querySelector(sidebarSelectors["4get"])) {
      port.postMessage({ searchTerm: searchTerm });
      observer.disconnect();
    }
  });
  observer.observe(document.body, { childList: true, subtree: true });
}
```

## Pre-Implementation Research Required

### DOM Structure Analysis
**Target**: http://192.168.2.36:8085/
**Required Information**:
1. HTML structure of search results page
2. Available sidebar/injection areas
3. CSS selectors for stable injection points
4. Search input field selectors (if needed for fallback)

### URL Structure Analysis
**Required Information**:
1. Confirm search parameter name (`s` vs `q` vs other)
2. Verify URL patterns for different search types
3. Test with various search terms and special characters

### Behavioral Analysis
**Required Testing**:
1. Page load timing and dynamic content loading
2. JavaScript-based layout changes
3. Responsive design considerations
4. Theme detection capabilities

## Testing Strategy

### Development Testing
1. **Local Extension Loading**: Test unpacked extension in browser
2. **Target Instance Testing**: Verify against http://192.168.2.36:8085/
3. **Cross-Instance Testing**: Test with other 4get instances if available

### Test Cases
1. **Basic Injection**: Verify linkding results appear in correct location
2. **Theme Handling**: Test auto/light/dark theme switching
3. **Search Term Parsing**: Test various search terms and special characters
4. **Error Handling**: Test with no linkding results, configuration errors
5. **Performance**: Verify no significant impact on search page load times

### Edge Cases
1. Empty search queries
2. Very long search terms
3. Special characters and Unicode in search terms
4. 4get instance errors or timeouts
5. Different 4get configurations/themes

## Implementation Priority

### Phase 1: Core Functionality
1. Search engine detection
2. Basic injection with placeholder selector
3. Search term extraction
4. Theme configuration foundation

### Phase 2: Integration
1. Configuration schema updates
2. Options UI integration
3. Proper CSS styling
4. Error handling

### Phase 3: Optimization
1. Special timing handling (if needed)
2. Performance optimization
3. Cross-instance compatibility
4. Documentation updates

## Future Considerations

### Multi-Instance Support
- Consider supporting multiple 4get instances simultaneously
- Configuration for custom 4get instance URLs
- Per-instance theme settings

### Advanced Features
- 4get-specific search filters support
- Integration with 4get's API (if beneficial)
- Custom injection positioning preferences

## Dependencies and Constraints

### Browser Extension Constraints
- Must work in both Firefox and Chrome
- Manifest v2 compatibility (current version)
- No additional permissions required

### 4get Instance Requirements
- Must be accessible from browser extension context
- Should have consistent DOM structure
- Compatible with content script injection

## Success Criteria

1. **Functional**: Linkding results successfully inject into 4get search pages
2. **Visual**: Injection appears consistent with other supported search engines
3. **Performance**: No noticeable impact on 4get search page performance
4. **Configurable**: Theme and behavior settings work correctly
5. **Stable**: No JavaScript errors or layout breaking
6. **Compatible**: Works across different 4get instance configurations

---

**Document Status**: Draft Specification  
**Target Implementation**: Future Development  
**Last Updated**: 2025-01-09  
**Requires**: DOM analysis of target 4get instance before implementation