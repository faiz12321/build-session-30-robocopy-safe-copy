# Critical release verification, Windows only, fresh temporary data only.
$ErrorActionPreference='Stop'
function Check($ok,$name){if(-not $ok){throw "FAIL: $name"};"PASS: $name"}
$start=Get-Location
function Setup {
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

}
try {
 Setup | Out-Null
 $work=(Get-Location).Path
 Check ((Get-ChildItem old-pc -Recurse -File).Count -eq 3) 'setup creates 3 source files'
 Check (((Get-ChildItem old-pc -Recurse -File|Measure-Object Length -Sum).Sum) -eq 53) 'setup source byte count is 53'
 $before=@{};Get-ChildItem old-pc -Recurse -File|ForEach-Object{$before[$_.FullName]=(Get-FileHash -LiteralPath $_.FullName).Hash}
 robocopy old-pc new-pc /E /L | Out-Null
 Check ($LASTEXITCODE -eq 1) 'dry run exit 1'
 Check (-not(Test-Path new-pc)) 'dry run creates no destination'
 robocopy old-pc new-pc /E | Out-Null
 Check ($LASTEXITCODE -eq 1) 'copy exit 1'
 Check ((Get-ChildItem new-pc -Recurse -File).Count -eq 3) 'copy produces 3 files'
 foreach($source in (Get-ChildItem old-pc -Recurse -File)) {
  $rel=$source.FullName.Substring((Resolve-Path old-pc).Path.Length+1)
  Check ((Get-FileHash -LiteralPath $source.FullName).Hash -eq (Get-FileHash -LiteralPath (Join-Path new-pc $rel)).Hash) "byte-identical copied file $rel"
 }
 robocopy old-pc new-pc /E /L | Out-Null
 Check ($LASTEXITCODE -eq 0) 'second dry run exit 0'
 robocopy keep mirror-demo /MIR /L | Out-Null
 Check ($LASTEXITCODE -eq 3) 'mirror dry run exit 3'
 Check (Test-Path mirror-demo/only-here.txt) 'mirror dry run preserves extra'
 robocopy keep mirror-demo /MIR | Out-Null
 Check ($LASTEXITCODE -eq 3) 'mirror exit 3'
 Check (-not(Test-Path mirror-demo/only-here.txt)) 'mirror removes extra only in demo'
 Check (Test-Path mirror-demo/important.txt) 'mirror copies important file'
 foreach($source in (Get-ChildItem old-pc -Recurse -File)) {
  Check ($before[$source.FullName] -eq (Get-FileHash -LiteralPath $source.FullName).Hash) "original source unchanged $($source.Name)"
 }
 Setup | Out-Null
 $work2=(Get-Location).Path
 Check ($work -ne $work2) 'second setup uses a new folder'
 Check (Test-Path (Join-Path $work 'old-pc/Documents/cv.txt')) 'second setup leaves first folder untouched'
 'PASS: all critical release checks passed'
} finally {
 Set-Location $start
 foreach($p in @($work,$work2)) {
  if($p -and (Split-Path $p -Leaf) -like 'robocopy-practice-*'){Remove-Item -LiteralPath $p -Recurse -Force}
 }
}
