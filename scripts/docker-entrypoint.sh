#!/bin/bash
set -e
set -u

if [ "$1" = 'owlh' ]; then

    #echo 'dummy' > /etc/modules-load.d/dummy.conf
    #echo 'install dummy /sbin/modprobe --ignore-install dummy; /sbin/ip link set name owlh dev dummy0' > /etc/modprobe.d/dummy.conf
#    echo "NOZEROCONF=yes" >> /etc/sysconfig/network
#    modprobe -v dummy numdummies=1

    export GOPATH=/usr/local/owlh
    cd /usr/local/owlh/src/owlhnode
    ./owlhnode  > /dev/null 2>&1

    /sbin/ip link add owlh type dummy 
    /sbin/ip link set owlh mtu 65535

#    /sbin/modprobe --ignore-install dummy
#    /sbin/ip link set name owlh dev dummy0
#    /sbin/ip link set owlh mtu 65535
    ifup owlh

    systemctl enable owlhnode ; systemctl start owlhnode

    #exec gosu /usr/bin/init "$@"
#    exec /usr/local/owlh/src/owlhnode/owlhnode
    #exec /bin/bash
fi

exec "$@"