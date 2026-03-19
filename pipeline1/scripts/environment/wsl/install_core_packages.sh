#!/usr/bin/env bash

info "Installing common packages..."
sudo apt-get install -y build-essential
sudo apt-get install -y libgtk2.0-0 libgtk-3-0 libgbm-dev
sudo apt-get install -y libnotify-dev libnss3 libxss1 libasound2 libxtst6 xauth xvfb
