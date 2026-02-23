$dir = "d:\magang\tugas day 10\web 1"
$files = Get-ChildItem -Path $dir -Filter "*.html"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # 1. Remove Bootstrap preload
    $content = $content -replace '<link rel="preload" as="style" href="https://cdn\.jsdelivr\.net/npm/bootstrap[^>]+" />\s*', ''

    # 2. Remove SVG preloads
    $content = $content -replace '<link rel="preload" as="image"[^>]+fetchpriority="high"[^>]+/>\s*', ''

    # 3. Find and replace <img fetchpriority="high">
    $pattern = '(?s)<img\s+src="images/([^"]+)\.svg"\s*alt="([^"]+)"(.*?)fetchpriority="high"(.*?)/>'
    
    $matches = [regex]::Matches($content, $pattern)
    foreach ($m in $matches) {
        $imgTag = $m.Groups[0].Value
        $svgName = $m.Groups[1].Value
        $altText = $m.Groups[2].Value
        
        $svgPath = Join-Path $dir "images\$svgName.svg"
        if (Test-Path $svgPath) {
            $svgContent = Get-Content $svgPath -Raw
            
            # Modify SVG tag
            $svgContent = $svgContent -replace '(?s)<svg(.*?)width="[^"]+"(.*?)>', '<svg$1$2>'
            $svgContent = $svgContent -replace '(?s)<svg(.*?)height="[^"]+"(.*?)>', '<svg$1$2>'
            $newSvgTag = '<svg preserveAspectRatio="xMidYMid slice" style="width: 100%; height: 100%; object-fit: cover; position: absolute; inset: 0;" role="img" aria-label="' + $altText + '" '
            $svgContent = $svgContent -replace '<svg ', $newSvgTag
            
            $content = $content.Replace($imgTag, $svgContent)
        }
    }

    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
