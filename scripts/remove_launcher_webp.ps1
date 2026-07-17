$items = Get-ChildItem -Path 'app/src/main/res' -Recurse -File -Filter '*.webp' | Where-Object { $_.Name -eq 'ic_launcher.webp' -or $_.Name -eq 'ic_launcher_round.webp' }
foreach ($it in $items) {
    Write-Output "Removing: $($it.FullName)"
    Remove-Item -Force -LiteralPath $it.FullName -ErrorAction Stop
}
Write-Output "Done"
