# Copy files to a new PC: preview first, avoid /MIR

Teaching files for AI Tools That Work, build session 30.

Windows only. The interactive lesson is a replay of recorded results, not a live terminal. The commands in this repository run for real if you run them yourself.

## Practice safely

Read `setup-practice.ps1`, then run it in Windows PowerShell. It creates five tiny made-up files inside a uniquely named temporary folder and switches that PowerShell window into it. No existing folder is reused and nothing is deleted. Keep that same window open while following the lesson commands.

Robocopy /E does not remove extra destination files, but it can overwrite same-name files. /MIR also deletes destination extras. Never point the practice commands at your real data. Keep separate backups.

## Check the lesson

`verify30.ps1` is a self-contained Windows test of the setup, dry runs, byte-identical copy, unchanged sources and a mirror deletion confined to disposable data. It checks 20 conditions and deletes only the temporary folders it created. CI runs on standard GitHub-hosted Windows. Ubuntu is not applicable to Robocopy.

The original recorded session ran twice with identical outputs on 16 October 2026. Its seven displayed command outputs are preserved in the lesson. The separate critical Windows checks also ran twice with identical results. Clock values in the lesson recording are replaced with a time-of-day marker; speed lines are omitted. The replay's second dry run checks pending work, not byte integrity. The separate release test uses SHA-256 hashes.

Reference: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy

MIT license for this teaching code. No warranty. No personal files, real user data, analytics or credentials are included.
