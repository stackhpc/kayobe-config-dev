#!/bin/bash

set -e
set -o pipefail

# Install extra kernel modules and NFS utils
if $(which dnf >/dev/null 2>&1); then
    sudo dnf -y install kernel-modules-extra nfs-utils
fi

# Configure local networking.
if ! sudo ip l show breth1 >/dev/null 2>&1; then
    sudo ip l add breth1 type bridge
    sudo ip l set breth1 up
    sudo ip a add 192.168.33.3/24 dev breth1
    sudo ip l add dummy1 type dummy
    sudo ip l set dummy1 up
    sudo ip l set dummy1 master breth1
fi

# Configure NFS server
sudo mkdir -p /export/cinder
echo "/export/cinder 192.168.33.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee /etc/exports
sudo systemctl start nfs-server
sudo exportfs -ra

echo
echo "All done!"
