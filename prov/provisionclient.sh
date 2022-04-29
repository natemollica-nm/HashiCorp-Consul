#!/bin/bash
# Consul Directory/IP Variables
VAGRANT_CONSUL_DIR="/vagrant/consul"
CONSUL_CFG_DIR="/etc/consul.d"
CONSUL_OP_DIR="/opt/consul"
CONSUL_DATA_DIR="$CONSUL_OP_DIR/data"

# Add the official HashiCorp Linux repository/Install Consul Enterprise on Vbox VM
apt-get update
apt-get -y -q install curl wget software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# apt-get -y -q install consul-enterprise
apt-get -y -q install consul=1.11.4

# Make Consul Specific Directories
sudo mkdir -p $CONSUL_CFG_DIR
sudo mkdir -p $CONSUL_OP_DIR
sudo mkdir -p $CONSUL_DATA_DIR
sudo chown --recursive vagrant:vagrant $CONSUL_CFG_DIR
sudo chown --recursive vagrant:vagrant $CONSUL_OP_DIR

# Copy Consul Server config to local config directory.
cp "$VAGRANT_CONSUL_DIR/configs/$HOSTNAME.hcl" $CONSUL_CFG_DIR/consul.hcl

# Copy Vagrant Specific Consul Unit File to /etc/systemd/system / Adjust permissions
sudo cp /vagrant/consul/configs/consul.service /etc/systemd/system/consul.service
sudo chmod --reference=/etc/systemd/system/default.target.wants /etc/systemd/system/consul.service
# Create temp script to reload systemd daemon loader.
cat <<-RELOAD > /etc/consul.d/reload.sh
#!/bin/bash
sudo systemctl enable consul.service
sudo systemctl daemon-reload &>/dev/null
sleep 3
RELOAD
chmod +x /etc/consul.d/reload.sh
. /etc/consul.d/reload.sh

VALID_CFG=$( consul validate $CONSUL_CFG_DIR/consul.hcl )
if [ "$VALID_CFG" == 'Configuration is valid!' ]; then
  echo "Valid consul.hcl Configuration with Gossip Encryption! Starting consul service...."
  sudo systemctl start consul
fi

# UNCOMMENT FOR LOCAL ZIP CONSUL AGENT INSTALLATION (Ensure apt-get install is commented-out if using)
# cd ~
# wget -q https://releases.hashicorp.com/consul/1.11.4/consul_1.11.4_linux_amd64.zip
# wget -q https://releases.hashicorp.com/consul/1.11.4+ent/consul_1.11.4+ent_linux_amd64.zip
# unzip *.zip
# mv consul /usr/bin/consul
# rm *.zip
# cp $VAGRANT_CONSUL_DIR/configs/${HOSTNAME}.hcl $CONSUL_CFG_DIR/consul.hcl
# sudo chmod 640 $CONSUL_CFG_DIR/consul.hcl
# Enable consul.service long-running daemon and reload systemctl
# sudo sh -c 'systemctl enable consul.service'
# sudo sh -c 'systemctl daemon-reload'

# UNCOMMENT TO INSTALL ENVOY
# curl -L https://func-e.io/install.sh | bash -s -- -b /usr/local/bin
# func-e use 1.18.3
# sudo cp ~/.func-e/versions/1.18.3/bin/envoy /usr/local/bin/