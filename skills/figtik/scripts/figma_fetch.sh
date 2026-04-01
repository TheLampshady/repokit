#!/bin/bash
# Fetches Figma node data and image URLs for a given file and node ID.
# Usage: ./figma_fetch.sh <file_key> <node_id> <output_dir>
#
# Requires FIGMA_API_KEY environment variable (set in ~/.bash_profile or ~/.zshrc)

set -euo pipefail

FILE_KEY="${1:?Usage: figma_fetch.sh <file_key> <node_id> <output_dir>}"
NODE_ID="${2:?Usage: figma_fetch.sh <file_key> <node_id> <output_dir>}"
OUTPUT_DIR="${3:?Usage: figma_fetch.sh <file_key> <node_id> <output_dir>}"

if [[ -z "${FIGMA_API_KEY:-}" ]]; then
  echo "ERROR: FIGMA_API_KEY environment variable is not set." >&2
  echo "" >&2
  echo "To fix this, add the following to your shell profile (~/.bash_profile or ~/.zshrc):" >&2
  echo "" >&2
  echo "  export FIGMA_API_KEY=\"your-figma-personal-access-token\"" >&2
  echo "" >&2
  echo "Then restart your terminal or run: source ~/.bash_profile" >&2
  echo "" >&2
  echo "You can generate a token at: https://www.figma.com/developers/api#access-tokens" >&2
  exit 1
fi

TOKEN="$FIGMA_API_KEY"

mkdir -p "$OUTPUT_DIR"

# URL-encode the node ID (replace : with %3A)
NODE_ID_ENCODED="${NODE_ID//:/%3A}"

echo "Fetching Figma node data for file=$FILE_KEY node=$NODE_ID ..."

# --- Fetch node JSON ---
HTTP_CODE=$(curl -s -w "%{http_code}" -o "$OUTPUT_DIR/figma_raw.json" \
  "https://api.figma.com/v1/files/${FILE_KEY}/nodes?ids=${NODE_ID_ENCODED}" \
  -H "X-Figma-Token: ${TOKEN}")

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "ERROR: Figma API returned HTTP $HTTP_CODE" >&2
  cat "$OUTPUT_DIR/figma_raw.json" >&2
  exit 1
fi

echo "Node data saved to $OUTPUT_DIR/figma_raw.json"

# Create images dir before parallel jobs to avoid race condition
mkdir -p "$OUTPUT_DIR/images"

# --- Parallel fetch: PNG, SVG, and metadata are independent ---
# Run all three concurrently after the critical node fetch succeeds.

# Background job 1: PNG fetch + download
(
  echo "Fetching rendered image URLs (PNG @2x) ..."
  IMG_CODE=$(curl -s -w "%{http_code}" -o "$OUTPUT_DIR/figma_images.json" \
    "https://api.figma.com/v1/images/${FILE_KEY}?ids=${NODE_ID_ENCODED}&format=png&scale=2" \
    -H "X-Figma-Token: ${TOKEN}")

  if [[ "$IMG_CODE" == "200" ]]; then
    echo "Image URLs saved to $OUTPUT_DIR/figma_images.json"
    echo "Downloading rendered PNG(s) ..."
    python3 -c "
import json, urllib.request, os, sys
with open('$OUTPUT_DIR/figma_images.json') as f:
    data = json.load(f)
images = data.get('images', {})
for node_id, url in images.items():
    if url:
        safe_name = node_id.replace(':', '-')
        out_path = os.path.join('$OUTPUT_DIR/images', f'{safe_name}.png')
        try:
            urllib.request.urlretrieve(url, out_path)
            print(f'  Downloaded: {out_path}')
        except Exception as e:
            print(f'  WARNING: Failed to download {node_id}: {e}', file=sys.stderr)
" 2>&1
  else
    echo "WARNING: Image fetch returned HTTP $IMG_CODE (non-fatal)" >&2
  fi
) &
PID_PNG=$!

# Background job 2: SVG fetch + download
(
  echo "Fetching SVG export URLs ..."
  SVG_CODE=$(curl -s -w "%{http_code}" -o "$OUTPUT_DIR/figma_svg.json" \
    "https://api.figma.com/v1/images/${FILE_KEY}?ids=${NODE_ID_ENCODED}&format=svg" \
    -H "X-Figma-Token: ${TOKEN}")

  if [[ "$SVG_CODE" == "200" ]]; then
    echo "SVG URLs saved to $OUTPUT_DIR/figma_svg.json"
    echo "Downloading SVG(s) ..."
    python3 -c "
import json, urllib.request, os, sys
with open('$OUTPUT_DIR/figma_svg.json') as f:
    data = json.load(f)
images = data.get('images', {})
for node_id, url in images.items():
    if url:
        safe_name = node_id.replace(':', '-')
        out_path = os.path.join('$OUTPUT_DIR/images', f'{safe_name}.svg')
        try:
            urllib.request.urlretrieve(url, out_path)
            print(f'  Downloaded: {out_path}')
        except Exception as e:
            print(f'  WARNING: Failed to download SVG {node_id}: {e}', file=sys.stderr)
" 2>&1
  else
    echo "WARNING: SVG fetch returned HTTP $SVG_CODE (non-fatal)" >&2
  fi
) &
PID_SVG=$!

# Background job 3: File metadata
(
  echo "Fetching file metadata ..."
  META_CODE=$(curl -s -w "%{http_code}" -o "$OUTPUT_DIR/figma_file_meta.json" \
    "https://api.figma.com/v1/files/${FILE_KEY}?depth=1" \
    -H "X-Figma-Token: ${TOKEN}")

  if [[ "$META_CODE" == "200" ]]; then
    echo "File metadata saved to $OUTPUT_DIR/figma_file_meta.json"
  else
    echo "WARNING: File metadata fetch returned HTTP $META_CODE (non-fatal)" >&2
  fi
) &
PID_META=$!

# Wait for all parallel jobs to finish
wait $PID_PNG $PID_SVG $PID_META

echo "Done. Output in $OUTPUT_DIR/"
