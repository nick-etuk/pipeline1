function add_aliases {
    if (get-alias | findstr 'grep') { return }
    New-Alias -Scope Global grep findstr
}

function gch { git checkout $args }
function gs { git status }
function gls { git log --show-signature }

function p1 { python $P1_ROOT_SCRIPT/../p1.py $args }
function p1pf { p1 pf }
function cdpf { cd F:\repos\portfolio }
function cdp1 { cd F:\repos\pipeline1 }

remove-alias -name h -ErrorAction SilentlyContinue
function h { 
  $find = $args; 
  Write-Host "Finding in full history using {`$_ -like `"*$find*`"}"; 
  Get-Content (Get-PSReadlineOption).HistorySavePath | ? {$_ -like "*$find*"} | Get-Unique | more 
}
