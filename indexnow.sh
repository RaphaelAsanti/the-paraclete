#!/bin/bash

# Your GitHub Pages base URL
BASE="https://raphaelasanti.github.io"

# Check if HEAD~1 exists
if git rev-parse HEAD~1 >/dev/null 2>&1; then
  # Normal diff between last two commits
  CHANGED=$(git diff --name-only HEAD~1 HEAD | grep '.html')
else
  # First commit or shallow history: treat all HTML files as changed
  CHANGED=$(git ls-files '*.html')
fi

# If nothing changed, exit quietly
if [ -z "$CHANGED" ]; then
  echo "No HTML changes detected."
  exit 0
fi

# Build URL list
URLS=$(printf '%s\n' $CHANGED | sed "s|^|$BASE/|")

# Build JSON payload using jq
JSON=$(jq -n \
  --arg key "$INDEXNOW_KEY" \
  --arg urls "$URLS" \
  '{
    host: "raphaelasanti.github.io",
    key: $key,
    urlList: ($urls | split("\n"))
  }'
)

# Send to IndexNow endpoint
curl -X POST \
  -H "Content-Type: application/json" \
  -d "$JSON" \
  "https://api.indexnow.org/indexnow"

echo "IndexNow submission sent."
