$files = Get-ChildItem -Filter *.html
foreach ($f in $files) {
    $content = Get-Content $f.FullName -Raw

    # Remove expensive filters
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, 'backdrop-filter:[^;]+;', '')
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '-webkit-backdrop-filter:[^;]+;', '')
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, 'filter:\s*blur[^;]+;', '')
    
    # Remove animation that triggers layout/paint
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, 'animation:\s*wa-pulse[^;]+;', '')

    # Defer fonts
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(<link[^>]+href="https://fonts\.googleapis\.com[^>]+")\s*rel="stylesheet"([^>]*>)', '$1 rel="stylesheet" media="print" onload="this.media=''all''"$2`n    <noscript>$1 rel="stylesheet"$2</noscript>')

    # Defer icons
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(<link[^>]+href="https://cdn\.jsdelivr\.net/npm/bootstrap-icons[^>]+")\s*rel="stylesheet"([^>]*>)', '$1 rel="stylesheet" media="print" onload="this.media=''all''"$2`n    <noscript>$1 rel="stylesheet"$2</noscript>')

    # Preload and fetchpriority hero images
    $heroMatches = [System.Text.RegularExpressions.Regex]::Matches($content, '<img[^>]+src="([^"]+)"[^>]*>')
    foreach ($m in $heroMatches) {
        if ($m.Value -match 'loading="eager"' -or ($f.Name -ne 'index.html' -and $m.Value -match 'width="1200"')) {
            $imageUrl = $m.Groups[1].Value
            if ($content -notmatch "rel=`"preload`" as=`"image`"") {
                $content = $content -replace '</head>', "    <link rel=`"preload`" as=`"image`" href=`"$imageUrl`" fetchpriority=`"high`">`n</head>"
            }
            if ($m.Value -notmatch 'fetchpriority') {
                $newImg = $m.Value -replace '<img', '<img fetchpriority="high"'
                $content = $content.Replace($m.Value, $newImg)
            }
            break
        }
    }

    Set-Content -Path $f.FullName -Value $content -Encoding UTF8
}
