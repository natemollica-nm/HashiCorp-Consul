#!/bin/bash
# Script local variables
VAGRANT_CONSUL_DIR="/vagrant/consul"
VAGRANT_USR_SSH_DIR="/home/vagrant/.ssh"
AUTH_KEYS="$VAGRANT_USR_SSH_DIR/authorized_keys"
VAGRANT_AUTH=$VAGRANT_CONSUL_DIR/ssh/authorized_keys
cp $VAGRANT_AUTH $AUTH_KEYS

vagrant ssh "192.168.56.20" -c "sudo cp $VAGRANT_AUTH $AUTH_KEYS"
