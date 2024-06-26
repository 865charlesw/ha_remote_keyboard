#!/usr/bin/env bash

set -e

sudo apt-get update
sudo apt-get install -y python3-venv python3-dev
cd "$(dirname "$0")"
project_name="$(basename "$(pwd)")"
python3 -m venv "venv_$project_name"
source "venv_$project_name/bin/activate"
pip install -r requirements.txt
python configure.py
cat <<- EOF | sudo tee "/etc/systemd/system/$project_name.service" > /dev/null
    [Unit]
    Description=Home Assistant Remote Keyboard Service
    After=network-online.target

    [Service]
    ExecStart=$(which python) $(pwd)/main.py
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now "$project_name"
