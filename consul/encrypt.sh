#!/bin/bash
# Script local variables
VAGRANT_CONSUL_DIR="/vagrant/consul"
CONSUL_KEYGEN_OUT=$VAGRANT_CONSUL_DIR/key
# Generate Gossip Encryption key
touch $CONSUL_KEYGEN_OUT
consul keygen > $CONSUL_KEYGEN_OUT
GOSSIP_KEY=$( cat $CONSUL_KEYGEN_OUT )
# Update config.hcl with keygen key (ALL NODES)
echo -ne "\nencrypt = \"$GOSSIP_KEY\"\n" >> "$VAGRANT_CONSUL_DIR/configs/consul-server-1.hcl"
echo -ne "\nencrypt = \"$GOSSIP_KEY\"\n" >> "$VAGRANT_CONSUL_DIR/configs/consul-server-2.hcl"
echo -ne "\nencrypt = \"$GOSSIP_KEY\"\n" >> "$VAGRANT_CONSUL_DIR/configs/consul-server-3.hcl"
echo -ne "\nencrypt = \"$GOSSIP_KEY\"\n" >> "$VAGRANT_CONSUL_DIR/configs/consul-server-4.hcl"
echo -ne "\nencrypt = \"$GOSSIP_KEY\"\n" >> "$VAGRANT_CONSUL_DIR/configs/consul-server-5.hcl"
echo -ne "\nencrypt = \"$GOSSIP_KEY\"\n" >> "$VAGRANT_CONSUL_DIR/configs/consul-server-6.hcl"
echo -ne "\nencrypt = \"$GOSSIP_KEY\"\n" >> "$VAGRANT_CONSUL_DIR/configs/consul-client-1.hcl"

# TLS Settings
#  consul tls ca create
#  consul tls cert create -server -dc dc1 -domain consul
#scp -S ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null ./*.pem  consul-server-2:/etc/consul.d/
#scp -S ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null ./*.pem  consul-server-3:/etc/consul.d/
#scp -S ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null ./*.pem  consul-server-4:/etc/consul.d/
#scp -S ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null ./*.pem  consul-server-5:/etc/consul.d/
#scp -S ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null ./*.pem  consul-server-6:/etc/consul.d/
#  mv ./*.pem /etc/consul.d/
#  cat <<-CONFIG > $CONSUL_CFG_DIR/consul.hcl
#  verify_incoming = true
#  verify_outgoing = true
#  verify_server_hostname = true
#  ca_file   = "$CONSUL_CFG_DIR/consul-agent-ca.pem"
#  cert_file = "$CONSUL_CFG_DIR/dc1-server-consul-0.pem"
#  key_file  = "$CONSUL_CFG_DIR/dc1-server-consul-0-key.pem"
#  CONFIG
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-2 chown vagrant:vagrant /etc/consul.d/*
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-2 sudo systemctl restart consul
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-3 chown vagrant:vagrant /etc/consul.d/*
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-3 sudo systemctl restart consul
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-4 chown vagrant:vagrant /etc/consul.d/*
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-4 sudo systemctl restart consul
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-5 chown vagrant:vagrant /etc/consul.d/*
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-5 sudo systemctl restart consul
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-6 chown vagrant:vagrant /etc/consul.d/*
#ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null consul-server-6 sudo systemctl restart consul
#  chown vagrant:vagrant /etc/consul.d/*
#  sudo systemctl restart consul