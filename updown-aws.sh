#!/bin/sh
exec 1<&-
exec 2<&-
exec 1<>/var/log/dlog
exec 2>&1

[ "$PLUTO_VERB" = "up-host" ] || exit 0

echo "$0 $@"
echo "================================="
env
sleep 1

ping  -c1 $PLUTO_PEER

ip link set dev $PLUTO_CONNECTION down >/dev/null 2>/dev/null
ip link del $PLUTO_CONNECTION >/dev/null 2>/dev/null

ip link add $PLUTO_CONNECTION type gretap local $PLUTO_ME remote $PLUTO_PEER
ip link set dev $PLUTO_CONNECTION mtu 1360
ip link set dev $PLUTO_CONNECTION up

#TODO aquire new ENI automatically
brctl addbr peering
brctl addif peering eth1
brctl addif peering $PLUTO_CONNECTION
ip link set dev peering up
ip link set dev eth1 up

AWS_PEERING_MAC=$(ip link show dev eth1 | grep link/ether | awk '{print $2}')

ebtables -t nat -A PREROUTING  -d $AWS_PEERING_MAC  -i eth1 -j dnat --to-destination 22:22:22:fa:ca:de
ebtables -t nat -A POSTROUTING -s 22:22:22:fa:ca:de -o eth1 -j snat --to-source $AWS_PEERING_MAC --snat-arp

AWS_PEERING_IP=$(curl -s --fail http://169.254.169.254/2016-09-02/meta-data/network/interfaces/macs/$AWS_PEERING_MAC/local-ipv4s)
AWS_PEERING_NET=$(curl -s --fail http://169.254.169.254/2016-09-02/meta-data/network/interfaces/macs/$AWS_PEERING_MAC/subnet-ipv4-cidr-block)
AWS_PEERING_GW=$(echo $AWS_PEERING_NET | cut -d '.' -f '1,2,3').1

#TODO: either run dhcp server, or figure out a way to bridge dhcp to aws
