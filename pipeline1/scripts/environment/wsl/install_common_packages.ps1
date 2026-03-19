
if (!(IsDistroInstalled 'ubuntu')) { return 0 }

WriteInfo "Installing common packages..."
wsl -u root apt-get install -y build-essential
wsl -u root apt-get install -y libgtk2.0-0 libgtk-3-0 libgbm-dev
wsl -u root apt-get install -y libnotify-dev libnss3 libxss1 libasound2 libxtst6 xauth xvfb
