#!/usr/bin/env bash
 if [ "$VM" = 'wsl' ]; then
    echo 'step install_ttab not for wsl'
    return
fi

return
sudo curl -sSfL https://raw.githubusercontent.com/mklement0/ttab/stable/bin/ttab -o /usr/local/bin/ttab
sudo chmod +x /usr/local/bin/ttab
