#!/bin/bash

CONTAINER_PATH=/var/lib/libvirt/lxc/centos-6-x86_64/rootfs

yum install libvirt python-virtinst libcgroup -y

SERVICES=(cgconfig messagebus libvirtd)

for SERVICE in $SERVICES
do
    sudo chkconfig --add $SERVICE
    sudo service $SERVICE start
done

# the majority of this script was taken from
# http://wiki.centos.org/HowTos/LXC-on-CentOS6

mkdir ${CONTAINER_PATH}/etc/yum.repos.d/ -p  
cat /etc/yum.repos.d/CentOS-Base.repo |sed s/'$releasever'/6/g > ${CONTAINER_PATH}/etc/yum.repos.d/CentOS-Base.repo
yum groupinstall core --installroot=${CONTAINER_PATH}/ --nogpgcheck -y
yum install plymouth libselinux-python --installroot=${CONTAINER_PATH}/ --nogpgcheck -y

cat > $CONTAINER_PATH/tmp/setup.sh <<SCRIPT
echo root |passwd root --stdin

#Fix root login on console
echo "pts/0" >>/etc/securetty
sed -i s/"session    required     pam_selinux.so close"/"#session    required     pam_selinux.so close"/g /etc/pam.d/login
sed -i s/"session    required     pam_selinux.so open"/"#session    required     pam_selinux.so open"/g /etc/pam.d/login
sed -i s/"session    required     pam_loginuid.so"/"#session    required     pam_loginuid.so"/g /etc/pam.d/login

#Configuring basic networking
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=lxc1.test.centos.org
EOF

cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
EOF

#Enabling sshd
chkconfig sshd on

# Fixing root login for sshd
sed -i s/"session    required     pam_selinux.so close"/"#session    required     pam_selinux.so close"/g /etc/pam.d/sshd
sed -i s/"session    required     pam_loginuid.so"/"#session    required     pam_loginuid.so"/g /etc/pam.d/sshd
sed -i s/"session    required     pam_selinux.so open env_params"/"#session    required     pam_selinux.so open env_params"/g /etc/pam.d/sshd

SCRIPT


chmod +x $CONTAINER_PATH/tmp/setup.sh

sudo chroot ${CONTAINER_PATH} /tmp/setup.sh
