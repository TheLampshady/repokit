#!/bin/bash
# Extracts a human-readable summary from raw Figma node JSON.
# Usage: ./parse_figma.sh <figma_raw.json> <output_dir>
#
# Produces:
#   - figma.json     (cleaned node document — the part that matters)
#   - summary.txt    (quick text summary of layers, text content, colors, styles, layout, interactions)

set -euo pipefail

RAW_JSON="${1:?Usage: parse_figma.sh <figma_raw.json> <output_dir>}"
OUTPUT_DIR="${2:?Usage: parse_figma.sh <figma_raw.json> <output_dir>}"

if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 required" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

python3 - "$RAW_JSON" "$OUTPUT_DIR" <<'PYEOF'
import json, sys, os

raw_path = sys.argv[1]
output_dir = sys.argv[2]

with open(raw_path) as f:
    data = json.load(f)

# Extract the node document from the response wrapper
nodes = data.get("nodes", {})
if not nodes:
    print("WARNING: No nodes found in response", file=sys.stderr)
    sys.exit(0)

# Get the first (usually only) node
node_id = list(nodes.keys())[0]
node_data = nodes[node_id]
document = node_data.get("document", {})
components = node_data.get("components", {})
styles = node_data.get("styles", {})

# Save cleaned node JSON
cleaned = {
    "node_id": node_id,
    "document": document,
    "components": components,
    "styles": styles,
}
with open(os.path.join(output_dir, "figma.json"), "w") as f:
    json.dump(cleaned, f, indent=2)

# --- Build summary ---
lines = []
lines.append(f"# Figma Node Summary")
lines.append(f"Node ID: {node_id}")
lines.append(f"Node Name: {document.get('name', 'Unknown')}")
lines.append(f"Node Type: {document.get('type', 'Unknown')}")
lines.append("")

# Collectors
texts = []
colors_seen = set()
fonts_seen = set()
interactive_elements = []
auto_layout_nodes = []
component_instances = []
constraints_seen = []

def walk(node, depth=0):
    indent = "  " * depth
    name = node.get("name", "")
    ntype = node.get("type", "")
    lines.append(f"{indent}- [{ntype}] {name}")

    # Text content
    if ntype == "TEXT":
        chars = node.get("characters", "")
        if chars:
            texts.append(chars)
            lines.append(f"{indent}  text: \"{chars[:80]}{'...' if len(chars) > 80 else ''}\"")

        # Font info
        style = node.get("style", {})
        if style:
            font = f"{style.get('fontFamily', '?')} {style.get('fontWeight', '')} {style.get('fontSize', '')}px"
            fonts_seen.add(font)
            lines.append(f"{indent}  font: {font}")
            line_height = style.get("lineHeightPx")
            letter_spacing = style.get("letterSpacing")
            if line_height:
                lines.append(f"{indent}  line-height: {line_height}px")
            if letter_spacing:
                lines.append(f"{indent}  letter-spacing: {letter_spacing}px")

    # Auto-layout properties
    layout_mode = node.get("layoutMode")
    if layout_mode:
        layout_info = {
            "name": name,
            "direction": layout_mode,
            "padding": {
                "top": node.get("paddingTop", 0),
                "right": node.get("paddingRight", 0),
                "bottom": node.get("paddingBottom", 0),
                "left": node.get("paddingLeft", 0),
            },
            "gap": node.get("itemSpacing", 0),
            "align": node.get("primaryAxisAlignItems", ""),
            "crossAlign": node.get("counterAxisAlignItems", ""),
            "sizing": {
                "horizontal": node.get("layoutSizingHorizontal", ""),
                "vertical": node.get("layoutSizingVertical", ""),
            },
        }
        auto_layout_nodes.append(layout_info)
        lines.append(f"{indent}  layout: {layout_mode} | gap: {layout_info['gap']}px | padding: {layout_info['padding']['top']}/{layout_info['padding']['right']}/{layout_info['padding']['bottom']}/{layout_info['padding']['left']}")
        if layout_info["sizing"]["horizontal"] or layout_info["sizing"]["vertical"]:
            lines.append(f"{indent}  sizing: h={layout_info['sizing']['horizontal']} v={layout_info['sizing']['vertical']}")

    # Constraints (for non-auto-layout positioning)
    constraints = node.get("constraints")
    if constraints:
        h = constraints.get("horizontal", "")
        v = constraints.get("vertical", "")
        if h or v:
            constraints_seen.append({"name": name, "horizontal": h, "vertical": v})

    # Component instances
    if ntype == "INSTANCE":
        comp_id = node.get("componentId", "")
        comp_name = components.get(comp_id, {}).get("name", comp_id)
        component_instances.append({"name": name, "component": comp_name, "componentId": comp_id})
        lines.append(f"{indent}  instance of: {comp_name}")

        # Variant properties (component overrides)
        overrides = node.get("componentProperties", {})
        if overrides:
            for prop_name, prop_val in overrides.items():
                lines.append(f"{indent}  variant: {prop_name} = {prop_val.get('value', '?')}")

    # Detect interactive elements (buttons, inputs, toggles, links)
    name_lower = name.lower()
    interactive_keywords = ["button", "btn", "input", "field", "toggle", "switch",
                           "checkbox", "radio", "select", "dropdown", "tab", "link",
                           "menu", "nav", "search", "slider", "rating"]
    if any(kw in name_lower for kw in interactive_keywords):
        interactive_elements.append({"name": name, "type": ntype, "depth": depth})

    # Colors from fills
    for fill in node.get("fills", []):
        color = fill.get("color", {})
        if color:
            r = int(color.get("r", 0) * 255)
            g = int(color.get("g", 0) * 255)
            b = int(color.get("b", 0) * 255)
            a = color.get("a", 1)
            hex_color = f"#{r:02x}{g:02x}{b:02x}"
            if a < 1:
                hex_color += f" (opacity: {a:.0%})"
            colors_seen.add(hex_color)

    # Colors from strokes
    for stroke in node.get("strokes", []):
        color = stroke.get("color", {})
        if color:
            r = int(color.get("r", 0) * 255)
            g = int(color.get("g", 0) * 255)
            b = int(color.get("b", 0) * 255)
            hex_color = f"#{r:02x}{g:02x}{b:02x}"
            colors_seen.add(hex_color)

    # Effects (shadows, blurs)
    for effect in node.get("effects", []):
        etype = effect.get("type", "")
        if etype:
            lines.append(f"{indent}  effect: {etype}")

    # Corner radius
    corner_radius = node.get("cornerRadius")
    if corner_radius:
        lines.append(f"{indent}  border-radius: {corner_radius}px")

    # Recurse into children
    for child in node.get("children", []):
        walk(child, depth + 1)

walk(document)

# --- Sections ---

lines.append("")
lines.append("## Text Content Found")
for t in texts:
    lines.append(f"  - \"{t[:120]}\"")

lines.append("")
lines.append("## Colors Used")
for c in sorted(colors_seen):
    lines.append(f"  - {c}")

lines.append("")
lines.append("## Fonts Used")
for f_entry in sorted(fonts_seen):
    lines.append(f"  - {f_entry}")

lines.append("")
lines.append("## Auto-Layout Nodes")
if auto_layout_nodes:
    for al in auto_layout_nodes:
        p = al["padding"]
        lines.append(f"  - {al['name']}: {al['direction']} | gap: {al['gap']}px | padding: {p['top']}/{p['right']}/{p['bottom']}/{p['left']}")
        if al["align"]:
            lines.append(f"    align: {al['align']} / {al['crossAlign']}")
else:
    lines.append("  (none detected)")

lines.append("")
lines.append("## Interactive Elements")
if interactive_elements:
    for ie in interactive_elements:
        lines.append(f"  - {ie['name']} [{ie['type']}]")
else:
    lines.append("  (none detected by name — review layer tree manually)")

lines.append("")
lines.append("## Component Instances")
if component_instances:
    for ci in component_instances:
        lines.append(f"  - {ci['name']} -> {ci['component']}")
else:
    lines.append("  (none)")

lines.append("")
lines.append(f"## Components Referenced: {len(components)}")
for comp_id, comp in components.items():
    lines.append(f"  - {comp.get('name', comp_id)}")

lines.append("")
lines.append(f"## Styles Referenced: {len(styles)}")
for style_id, style in styles.items():
    lines.append(f"  - {style.get('name', style_id)} ({style.get('styleType', '?')})")

summary = "\n".join(lines)
with open(os.path.join(output_dir, "summary.txt"), "w") as f:
    f.write(summary)

print(summary)
PYEOF

echo ""
echo "Cleaned JSON: $OUTPUT_DIR/figma.json"
echo "Summary: $OUTPUT_DIR/summary.txt"
