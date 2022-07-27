#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo '*** Adding APT package sources for Datadog'
sudo apt-key adv \
    --recv-keys \
    --keyserver 'hkp://keyserver.ubuntu.com:80' \
    D75CEA17048B9ACBF186794B32637D44F14F620E
echo 'deb https://apt.datadoghq.com/ stable 7' | sudo tee /etc/apt/sources.list.d/datadog.list


echo '*** Installing datadog-agent package'
sudo --preserve-env=DEBIAN_FRONTEND \
  sudo apt update 1>/dev/null \
    -o Dir::Etc::sourcelist="sources.list.d/datadog.list" \
    -o Dir::Etc::sourceparts="-" \
    -o APT::Get::List-Cleanup="0"
sudo apt install --yes datadog-agent 1>/dev/null

echo '*** Disabling datadog-agent service'
sudo systemctl disable --now datadog-agent.service

echo '*** Adding dd-agent to systemd-journal group (allow Datadog agent to stream journald logs)'
sudo usermod \
    --append \
    --groups=systemd-journal \
    dd-agent

# Disable monitoring of "squashfs" filesystems (e.g., /dev/loop# / snap mounts)
cat << CONFIG | sudo tee /etc/datadog-agent/conf.d/disk.d/conf.yaml
init_config: {}
instances:
  - file_system_blacklist:
      - "squashfs$"
    mount_point_blacklist:
       - '^/var/lib/(nomad|docker)/.*'
       - '^/run/docker/.*'
CONFIG
