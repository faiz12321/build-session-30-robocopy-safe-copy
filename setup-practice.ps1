# Creates only made-up files in a fresh, uniquely named temporary folder.
# No existing folder is reused and nothing is deleted.
$ErrorActionPreference = 'Stop'
$work = Join-Path ([IO.Path]::GetTempPath()) ('robocopy-practice-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
Set-Location -LiteralPath $work
New-Item -ItemType Directory -Path 'old-pc/Documents/school','old-pc/Pictures','keep','mirror-demo' | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $work 'old-pc/Documents/cv.txt'), "My CV text`r`n", $utf8)
[IO.File]::WriteAllText((Join-Path $work 'old-pc/Pictures/photo-notes.txt'), "Grandma photo scan note`r`n", $utf8)
[IO.File]::WriteAllText((Join-Path $work 'old-pc/Documents/school/essay.txt'), "Homework essay`r`n", $utf8)
[IO.File]::WriteAllText((Join-Path $work 'keep/important.txt'), "important`r`n", $utf8)
[IO.File]::WriteAllText((Join-Path $work 'mirror-demo/only-here.txt'), "only in the demo folder`r`n", $utf8)
Get-ChildItem 'old-pc','keep','mirror-demo' -Recurse | ForEach-Object { $_.LastWriteTime = [datetime]'2024-06-01T12:00:00' }
"Practice folder: $work"
'Keep this PowerShell window open. Run the lesson commands here, not in your real folders.'
