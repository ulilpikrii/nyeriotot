$files = Get-ChildItem -Path "d:\magang\tugas day 10\web 1" -Filter "*.html"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # 1. Preload Bootstrap CSS
    $targetCss = '<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />'
    $preloadCss = '<link rel="preload" as="style" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />' + "`r`n    " + $targetCss
    
    if (-not $content.Contains('<link rel="preload" as="style" href="https://cdn.jsdelivr.net/npm/bootstrap')) {
        $content = $content.Replace($targetCss, $preloadCss)
    }

    # 2. Add type="image/svg+xml" to LCP preload
    $content = $content -replace '<link rel="preload" as="image" href="images/([^"]+)\.svg" fetchpriority="high" />', '<link rel="preload" as="image" type="image/svg+xml" href="images/$1.svg" fetchpriority="high" />'

    # Save
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
