#!/bin/bash
# Script local variables
VAGRANT_CONSUL_DIR="/vagrant/consul"
VAGRANT_USR_SSH_DIR="/home/vagrant/.ssh"
AUTH_KEYS="$VAGRANT_USR_SSH_DIR/authorized_keys"
VAGRANT_AUTH=$VAGRANT_CONSUL_DIR/ssh/authorized_keys
# Update temp auth_keys file
SSH_KEY=$( cat $AUTH_KEYS )
if test -f $VAGRANT_AUTH; then
  echo -ne "\n$SSH_KEY\n" >> $VAGRANT_AUTH
else
  touch $VAGRANT_AUTH
  echo -ne "\n$SSH_KEY\n" >> $VAGRANT_AUTH
fi