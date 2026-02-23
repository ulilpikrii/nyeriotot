import os
import re

dir_path = r"d:\magang\tugas day 10\web 1"
files = [f for f in os.listdir(dir_path) if f.startswith("artikel-") and f.endswith(".html")]

for fname in files:
    fpath = os.path.join(dir_path, fname)
    with open(fpath, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. find the image used in og:image
    match = re.search(r'<meta property="og:image" content="([^"]+)"', content)
    if not match:
        continue
    img_src = match.group(1)
    
    # 2. Add preload for the image before <link href="https://fonts.googleapis.com
    preload_tag = f'<link rel="preload" as="image" href="{img_src}" fetchpriority="high" />\n    <link href="https://fonts.googleapis.com'
    content = re.sub(r'<link href="https://fonts\.googleapis\.com', preload_tag, content, count=1)
    
    # 3. Defer bootstrap-icons
    old_icons = r'<link href="https://cdn\.jsdelivr\.net/npm/bootstrap-icons@1\.11\.3/font/bootstrap-icons\.min\.css" rel="stylesheet" />'
    new_icons = '<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="preload" as="style" onload="this.onload=null;this.rel=\'stylesheet\'" />\n    <noscript><link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" /></noscript>'
    content = re.sub(old_icons, new_icons, content)
    
    # 4. Add fetchpriority="high" to loading="eager"
    content = content.replace('loading="eager"', 'loading="eager" fetchpriority="high"')
    
    # 5. Make scroll event listener passive
    content = content.replace("window.addEventListener('scroll', () => s.classList.toggle('show', scrollY > 400));", "window.addEventListener('scroll', () => s.classList.toggle('show', scrollY > 400), { passive: true });")
    
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(content)
