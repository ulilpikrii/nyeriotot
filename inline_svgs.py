import os
import re

dir_path = r"d:\magang\tugas day 10\web 1"
files = [f for f in os.listdir(dir_path) if f.endswith(".html")]

# Map SVG files to their inlined variants
svg_cache = {}

def get_inlined_svg(src, width, height, alt):
    if src not in svg_cache:
        path = os.path.join(dir_path, src)
        try:
            with open(path, 'r', encoding='utf-8') as f:
                svg_content = f.read()
        except FileNotFoundError:
            return None
        
        # Replace the <svg tag to add preserveAspectRatio, width, height, role, and aria-label
        # Remove original width/height to avoid conflicts and set our own styles
        svg_content = re.sub(r'<svg(.*?)width="[^"]+"(.*?)>', r'<svg\1\2>', svg_content)
        svg_content = re.sub(r'<svg(.*?)height="[^"]+"(.*?)>', r'<svg\1\2>', svg_content)
        
        # Add the necessary attributes for responsive full-coverage viewing
        svg_content = re.sub(r'<svg', f'<svg preserveAspectRatio="xMidYMid slice" style="width: 100%; height: 100%; object-fit: cover; position: absolute; inset: 0;" role="img" aria-label="{alt}" ', svg_content)
        svg_cache[src] = svg_content
    
    # We update the aria-label per instance just in case
    content = svg_cache[src]
    content = re.sub(r'aria-label="[^"]+"', f'aria-label="{alt}"', content)
    return content

for fname in files:
    fpath = os.path.join(dir_path, fname)
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Remove the Bootstrap CSS preload
    preload_css_pattern = r'<link rel="preload" as="style" href="https://cdn\.jsdelivr\.net/npm/bootstrap@5\.3\.3/dist/css/bootstrap\.min\.css"\s*/>'
    content = re.sub(preload_css_pattern, '', content)

    # 2. Remove the SVG preload
    preload_svg_pattern = r'<link rel="preload" as="image" type="image/svg\+xml" href="images/[^"]+" fetchpriority="high"\s*/>\s*'
    content = re.sub(preload_svg_pattern, '', content)

    # 3. Inline the hero images (those with fetchpriority="high")
    # Using a regex to match the hero <img> tag
    # Example: <img src="images/hero-bg.svg" alt="Pemandangan pegunungan dan hutan di Kota Batu Malang untuk kegiatan outbound" loading="eager" fetchpriority="high" width="1920" height="1080" />
    
    img_pattern = re.compile(r'<img\s+src="([^"]+)"\s+alt="([^"]+)"(?:\s+class="[^"]+")?\s+loading="eager"(?:\s+fetchpriority="high")?\s+width="(\d+)"\s+height="(\d+)"\s*/>')
    
    # Also handle multiline layout variations
    img_pattern_multi = re.compile(r'<img\s+src="([^"]+)"\s+alt="([^"]+)"\s+(?:class="[^"]+"\s+)?(?:style="[^"]+"\s+)?loading="eager"(?:\s+fetchpriority="high")?\s+width="(\d+)"\s+height="(\d+)"\s*/>|<img src="([^"]+)"\s*alt="([^"]+)"\s*loading="eager"\s*fetchpriority="high"\s*width="(\d+)"\s*height="(\d+)"\s*/>')

    def img_replacer(match):
        src = match.group(1) or match.group(5)
        alt = match.group(2) or match.group(6)
        w = match.group(3) or match.group(7)
        h = match.group(4) or match.group(8)
        
        # Ensure it's an SVG from the images folder
        if src.startswith("images/") and src.endswith(".svg"):
            inlined = get_inlined_svg(src, w, h, alt)
            if inlined:
                return inlined
        return match.group(0)

    content = re.sub(r'<img src="images/[^"]+\.svg"[^>]+fetchpriority="high"[^>]+/>', img_replacer, content)
    
    # Second pass for variations where fetchpriority might not be precisely matched
    content = re.sub(r'<img src="images/[^"]+\.svg"[^>]+loading="eager"[^>]+/>', img_replacer, content)


    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)
