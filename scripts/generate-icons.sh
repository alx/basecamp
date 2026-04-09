#!/usr/bin/env bash
# Generate icons using Stable Diffusion server on tailnet
# Usage: ./scripts/generate-icons.sh
# Output: static/images/icons/

set -e
SD_URL="http://fami-1.tail6a160.ts.net:1234"
OUT="static/images/icons"
mkdir -p "$OUT"

# Check server is available
if ! curl -sf "$SD_URL/sdapi/v1/sd-models" > /dev/null 2>&1; then
  echo "❌ SD server not reachable at $SD_URL — start it first"
  exit 1
fi

echo "✅ SD server online"

generate() {
  local name="$1"
  local prompt="$2"
  local outfile="$OUT/${name}.png"
  echo "🎨 Generating $name..."
  curl -sf "$SD_URL/sdapi/v1/txt2img" \
    -H "Content-Type: application/json" \
    -d "{
      \"prompt\": \"$prompt, icon design, flat style, minimalist, dark background, white lines, professional, high contrast\",
      \"negative_prompt\": \"text, letters, words, blurry, low quality\",
      \"steps\": 20,
      \"width\": 512,
      \"height\": 512,
      \"cfg_scale\": 7
    }" | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
img = data.get('images', [None])[0]
if img:
    with open('$outfile', 'wb') as f:
        f.write(base64.b64decode(img))
    print('  ✓ saved $outfile')
else:
    print('  ✗ no image returned')
"
  sleep 1
}

# Generate icons for BaseCamp AI site
generate "cpu"         "computer processor chip, circuit board, artificial intelligence"
generate "shield"      "shield security protection, privacy, lock"
generate "network"     "network nodes connected, mesh topology, distributed system"
generate "terminal"    "computer terminal command line interface, code prompt"
generate "brain"       "neural network brain, artificial intelligence nodes"
generate "server"      "server rack data center hardware"
generate "lightning"   "lightning bolt speed fast performance"
generate "database"    "database cylinder storage"
generate "lock"        "padlock closed security encryption"
generate "cloud-off"   "cloud with x mark offline disconnected"
generate "migration"   "arrow migration transform convert"

echo ""
echo "✅ Done — icons saved to $OUT/"
echo "Swap SVG icons in the HTML with: <img src=\"/images/icons/NAME.png\" ...>"
