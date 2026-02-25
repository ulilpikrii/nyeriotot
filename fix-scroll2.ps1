$files = @(
    'd:\magang\tugas day 10\web 1\artikel-2.html',
    'd:\magang\tugas day 10\web 1\artikel-3.html',
    'd:\magang\tugas day 10\web 1\artikel-4.html',
    'd:\magang\tugas day 10\web 1\artikel-5.html'
)

$old = @"
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: var(--bg-dark);
            color: var(--soft-cream);
            overflow-x: hidden
        }

        html {
            scroll-behavior: smooth
        }
"@

$new = @"
        html {
            scroll-behavior: smooth;
            overflow-x: hidden;
            max-width: 100vw;
        }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: var(--bg-dark);
            color: var(--soft-cream);
            overflow-x: hidden;
        }

        img {
            max-width: 100%;
            height: auto;
        }

        section, footer, nav, main {
            max-width: 100%;
        }

        .row {
            margin-left: 0;
            margin-right: 0;
        }

        .row > * {
            padding-left: 12px;
            padding-right: 12px;
        }
"@

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f)
    if ($content.Contains($old)) {
        $content = $content.Replace($old, $new)
        [System.IO.File]::WriteAllText($f, $content)
        Write-Host "Fixed: $f"
    }
    else {
        Write-Host "Pattern not found in: $f"
    }
}
