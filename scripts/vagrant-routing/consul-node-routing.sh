#!/bin/bash

LAN_IP_PREFIX_DC1="20.0.0"
WAN_IP_PREFIX="192.168.0"
LAN_IP_PREFIX_DC2="20.1.0"

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

function configure_node_iptables {
  log_info "[+] Starting Consul Node iptables Configuration..."

  log_info "[+] IPTABLES: Server RPC - Port 8300 (TCP)"
  sudo iptables -A OUTPUT -p tcp --dport 8300 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 8300 -j ACCEPT

  log_info "[+] IPTABLES: LAN Serf - Port 8301 (UDP/TCP)"
  sudo iptables -A OUTPUT -p tcp --dport 8301 -j ACCEPT
  sudo iptables -A OUTPUT -p udp --dport 8301 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 8301 -j ACCEPT
  sudo iptables -A INPUT -p udp --dport 8301 -j ACCEPT

  log_info "[+] IPTABLES: WAN Serf - Port 8302 (UDP/TCP)"
  sudo iptables -A OUTPUT -p tcp --dport 8302 -j ACCEPT
  sudo iptables -A OUTPUT -p udp --dport 8302 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 8302 -j ACCEPT
  sudo iptables -A INPUT -p udp --dport 8302 -j ACCEPT

  log_info "[+] IPTABLES: Consul DNS - Port 8600 (UDP/TCP)"
  sudo iptables -A OUTPUT -p tcp --dport 8600 -j ACCEPT
  sudo iptables -A OUTPUT -p udp --dport 8600 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 8600 -j ACCEPT
  sudo iptables -A INPUT -p udp --dport 8600 -j ACCEPT

  log_info "[+] IPTABLES: Consul HTTP - Port 8500 (UDP/TCP)"
  sudo iptables -A OUTPUT -p tcp --dport 8500 -j ACCEPT
  sudo iptables -A OUTPUT -p udp --dport 8500 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 8500 -j ACCEPT
  sudo iptables -A INPUT -p udp --dport 8500 -j ACCEPT

  log_info "[+] IPTABLES: Consul HTTPS - Port 8501 (UDP/TCP)"
  sudo iptables -A OUTPUT -p tcp --dport 8501 -j ACCEPT
  sudo iptables -A OUTPUT -p udp --dport 8501 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 8501 -j ACCEPT
  sudo iptables -A INPUT -p udp --dport 8501 -j ACCEPT

  log_info "[+] IPTABLES: Envoy gRPC - Port 8502 (UDP/TCP)"
  sudo iptables -A OUTPUT -p tcp --dport 8502 -j ACCEPT
  sudo iptables -A OUTPUT -p udp --dport 8502 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 8502 -j ACCEPT
  sudo iptables -A INPUT -p udp --dport 8502 -j ACCEPT

  log_info "[+] IPTABLES: Envoy Sidecar Proxy Min/Max - Ports 21000:21255 (UDP/TCP)"
  sudo iptables -A OUTPUT -p tcp --dport 21000:21255 -j ACCEPT
  sudo iptables -A OUTPUT -p udp --dport 21000:21255 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 21000:21255 -j ACCEPT
  sudo iptables -A INPUT -p udp --dport 21000:21255 -j ACCEPT

  log_info "[+] IPTABLES: Remote -> Local LAN Allow (All)"
  sudo iptables -A OUTPUT -s "$remote_lan_net.0/24" -d "$local_lan_net.0/24" -j ACCEPT
  sudo iptables -A INPUT -s "$local_lan_net.0/24" -d "$remote_lan_net.0/24" -j ACCEPT

  log_info "[+] Saving iptables configurations...."
  sudo echo -e 'y\ny\n' | sudo iptables-save

  log_info "[+] Disabling Ubuntu UFW...."
  sudo ufw disable
}

function configure_node_routing {
  local -r local_lan_net="$1"
  local -r remote_lan_net="$2"
  local -r wan_net="$3"


  sudo ip route add default via "$wan_net.101"
  sudo route del default gw 10.0.2.2
  sudo route add -net "$remote_lan_net.0" netmask 255.255.255.0 gw "$local_lan_net.1"
}

function run_consul_node_config {
  local local_lan_net="$LAN_IP_PREFIX_DC1"
  local wan_net="$WAN_IP_PREFIX"
  local remote_lan_net="$LAN_IP_PREFIX_DC2"

  while [[ $# -gt 0 ]]; do
    local key="$1"

    case "$key" in
      --local-lan)
        assert_not_empty "$key" "$2"
        local_lan_net="$2"
        shift
        ;;
      --remote-lan)
        assert_not_empty "$key" "$2"
        remote_lan_net="$2"
        shift
        ;;
      --wan-net)
        assert_not_empty "$key" "$2"
        wan_net="$2"
        shift
        ;;
      --help)
        print_usage
        exit
        ;;
      *)
        log_error "Unrecognized argument: $key"
        print_usage
        exit 1
        ;;
    esac

    shift
  done

  assert_not_empty "--local-lan" "$local_lan_net"
  assert_not_empty "--remote-lan" "$remote_lan_net"
  assert_not_empty "--wan-net" "$wan_net"

  log_info "[+] Starting Consul Node Network Configuration"
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

  configure_node_routing "$local_lan_net" "$remote_lan_net" "$wan_net"
  configure_node_iptables

  log_info "[+] Consul Node Routing and iptables Configuration Complete!"

}

run_consul_node_config "$@"