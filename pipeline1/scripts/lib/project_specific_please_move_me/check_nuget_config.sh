#!/usr/bin/env sh

check_nuget_config() {
  local token
  local search_string
  local file_path

  file_path="$HOME/.nuget/NuGet/NuGet.Config"
  if [ ! -f "$file_path" ]; then
    echo "NuGet.Config file not found at $file_path"
    return 1
  fi

  search_string='/<nhsapp-nuget-feed>/,/<\/nhsapp-nuget-feed>/s/.*ClearTextPassword" value="\([^"]*\)".*/\1/p'

  token=$(sed -n "$search_string" "$HOME/.nuget/NuGet/NuGet.Config")
  for f in nhsapp-nuget-feed nhsapp-pfsapi; do
    printf '%s: ' "$f"
    curl -s -o /dev/null -w '%{http_code}\n' -u "nhsapp:$token" \
      "https://pkgs.dev.azure.com/nhsapp/70d4deb2-d387-4e09-b546-da927c2186b9/_packaging/$f/nuget/v3/index.json"
  done

}
