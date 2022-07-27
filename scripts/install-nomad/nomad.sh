#!/usr/bin/env bash

set -euo pipefail

function create_user_with_group() {
    username="$1"
    home_dir="$2"
    if ! getent passwd "$username" >/dev/null ; then
        sudo /usr/sbin/adduser \
            --system \
            --home "$home_dir" \
            --no-create-home \
            --shell /bin/false \
            "$username"
        sudo /usr/sbin/groupadd --force --system "$username"
        sudo /usr/sbin/usermod --gid "$username" "$username"
    fi
}

function install_nomad() {
  echo "*** Installing Nomad v$NOMAD_VERSION"
  echo "*** Downloading Nomad to /tmp/nomad.zip"
  curl --silent "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" --output '/tmp/nomad.zip' --location --fail
  unzip -o "/tmp/nomad.zip" -d /tmp 1>/dev/null

  echo "*** Moving nomad binary to /usr/local/bin/nomad"
  sudo mv "/tmp/nomad" "/usr/local/bin/nomad"
  sudo chown "nomad:nomad" "/usr/local/bin/nomad"
  sudo chmod a+x "/usr/local/bin/nomad"
}

function setup_directories() {
  echo '*** Configuring nomad directories'
  # create and manage permissions on directories
  sudo mkdir --parents --mode=0755 \
    "/etc/nomad.d/tls" \
    "/var/lib/nomad" \
    "/var/log/nomad" \
    ;
  sudo chown --recursive "nomad:nomad" \
    "/etc/nomad.d" \
    "/var/lib/nomad" \
    "/var/log/nomad" \
    ;
}

function install_systemd_file() {
  systemd_file="$1"
  echo "*** Installing systemd file: $systemd_file"
  sudo cp "/tmp/packer_files/systemd/$systemd_file" /etc/systemd/system
  sudo chmod 0664 "/etc/systemd/system/$systemd_file"
  sudo systemctl disable --now "$systemd_file"
}

function install_utility_script() {
  utility_script="$1"
  destination_filename="$2"
  echo "*** Installing script $utility_script file as: $destination_filename"
  sudo cp --verbose "/tmp/packer_files/$utility_script" "/usr/local/bin/$destination_filename"
  sudo chmod 0755 "/usr/local/bin/$destination_filename"
}

create_user_with_group 'nomad' '/srv/nomad'
install_nomad
setup_directories
install_systemd_file nomad.service

