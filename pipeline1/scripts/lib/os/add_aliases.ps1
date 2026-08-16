function add_aliases {
    if (get-alias | findstr 'grep') { return }
    New-Alias -Scope Global grep findstr
}

function gch { git checkout $args }
function gs { git status }
function gls { git log --show-signature }

function p1 { python $P1_ROOT_SCRIPT/../p1.py $args }
function p1pf { p1 pf }
function cdpf { cd "$REPO_DIR\portfolio" }
function cdp1 { cd "$REPO_DIR\pipeline1" }

function cdweb { cd "$REPO_DIR\nhsapp\web" }
function cdand { cd "$REPO_DIR\nhsapp-android" }
function cdios { cd "$REPO_DIR\nhsapp-ios" }
function cdpa { cd "$REPO_DIR\1-sent-android-proto" }
function cdpb { cd "$REPO_DIR\1-sent-backend-proto" }

remove-alias -name h -ErrorAction SilentlyContinue
function h { 
  $find = $args; 
  Write-Host "Finding in full history using {`$_ -like `"*$find*`"}"; 
  Get-Content (Get-PSReadlineOption).HistorySavePath | ? {$_ -like "*$find*"} | Get-Unique | more 
}
