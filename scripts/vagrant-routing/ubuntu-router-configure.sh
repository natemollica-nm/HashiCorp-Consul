#!/bin/bash

function print_usage {
  echo
  echo "Usage: install-consul [OPTIONS]"
  echo
  echo "This script can be used to install Consul and its dependencies. This script has been tested with Vagrant hashicorp/bionic64 image."
  echo
  echo "Options:"
  echo
  echo -e "  --version\t\t\t  The version of Consul to install. Optional. Default: $CONSUL_VERSION."
  echo -e "  --datacenter\t\t\t  The name Consul server/client Datacenter. Provides appropriate modifications based on DC. Optional. Default: $CONSUL_DEFAULT_DC"
  echo -e "  --set-gossip-encryption\t  Bootstraps a new Gossip Encryption key if using consul-dc1-server-0. Updates consul.hcl configuration file with latest Gossip Encryption key."
  echo -e "  --enable-acls\t\t\t Applies default Consul ACL Allow All consul.hcl configuration entry to allow for initial ACL bootstrapping. Optional. Default: ACL Allow All Policy"
  echo -e "  --set-rpc-encryption\t\t  Bootstraps and initializes Consul local CA (consul-dc1-server-0 only). Generates server, client, and cli certificates for Primary and Secondary DCs. Applies applicable consul.hcl configuration stanza prior to initial agent start. Optional. "
  echo -e "  --enable-consul-connect\t  Applies the Consul Connect enabled stanza to the clients consul.hcl configuration prior to initial agent start (bootstraps Connect). Optional. "
  echo -e "  --enable-primary-mesh-gateway\t  Applies Consul Connect Configuration stanza modifications for client to act as Consul Envoy Primary Mesh GW (i.e., enable WAN federation). Optional. "
  echo -e "  --enable-secondary-mesh-gateway Applies Consul Connect Configuration stanza modifications for client to act as Secondary DC Consul Envoy Secondary Mesh GW (i.e., enable WAN Fed, set Primary DC, sets Primary DC Mesh GW IP and Port Information). Optional. "
  echo
  echo "Examples:"
  echo
  echo "  Install Consul Enterprise v1.11.5 with no Security Standards enabled/configured:"
  echo "    install-consul --version 1.11.5+ent --datacenter dc1"
  echo
  echo "  Install Consul Standard v1.10.9 with Consul Connect Enabled and no Security Standards enabled/configured:"
  echo "    install-consul --version 1.10.9 --datacenter dc1 --enable-consul-connect"
  echo
  echo "  Install Consul Enterprise v1.12.1 with Gossip/TLS Encryption, Connect, and Primary Mesh GW configurations enabled."
  echo "    install-consul --version 1.12.1+ent --datacenter dc1 --enable-consul-connect --enable-primary-mesh-gateway --set-gossip-encryption --set-rpc-encryption"
  echo
  echo "  Install Consul Standard v1.12.1 with Gossip/TLS Encryption, Connect, and Secondary Mesh GW configurations enabled. (Requires a Primary Mesh GW configured on alternate DC)."
  echo "    install-consul --version 1.12.1 --datacenter dc1 --enable-consul-connect --enable-primary-mesh-gateway --set-gossip-encryption --set-rpc-encryption"
  echo
}

function log {
  local -r level="$1"
  local -r message="$2"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local -r message="$1"
  log "INFO" "$message"
}

function log_warn {
  local -r message="$1"
  log "WARN" "$message"
}

function log_error {
  local -r message="$1"
  log "ERROR" "$message"
}

function assert_not_empty {
  local -r arg_name="$1"
  local -r arg_value="$2"

  if [[ -z "$arg_value" ]]; then
    log_error "The value for '$arg_name' cannot be empty"
    print_usage
    exit 1
  fi
}

function assert_is_installed {
  local -r name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    log_error "The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

function install_dependencies {
  log_info "[+] Installing dependencies...."
  sudo apt-get update
  log_info "[+] Installing Ubuntu networking dependencies..."
  sudo apt-get -y -qq install curl wget software-properties-common jq unzip traceroute nmap socat
  log_info "[+] Installing iptables-persistent...."
  sudo apt-get update && sudo apt-get -y -qq iptables-persistent
}

function configure_vagrant_router {

  log_info "[+] Configuring iptables for localhost ethernet adapters...."
  sudo iptables -A FORWARD -i  eth3 -o eth2 -j ACCEPT
  sudo iptables -A FORWARD -i  eth3 -o eth1 -j ACCEPT
  log_info "[+] Configuring NAT for localhost ethernet adapters...."
  sudo iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE
  sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
  log_info "[+] Removing default gateway via 10.0.2.2...."
  sudo ip route del default via 10.0.2.2
  log_info "[+] Saving iptables configurations...."
  sudo echo -e 'y\ny\n' | sudo iptables-save
  log_info "[+] Disabling Ubuntu UFW...."
  sudo ufw disable
}

function run_router_config {
  log_info "[+] Starting Ubuntu Router Configuration"
  install_dependencies
  log_info "[+] Verifying dependencies..."
  assert_is_installed "curl"
  assert_is_installed "wget"
  assert_is_installed "jq"
  assert_is_installed "unzip"
  assert_is_installed "traceroute"
  assert_is_installed "nmap"
  assert_is_installed "socat"
  assert_is_installed "iptables-save"
  configure_vagrant_router
  log_info "[+] Ubuntu Router Configuration Complete!"
}

run_router_config