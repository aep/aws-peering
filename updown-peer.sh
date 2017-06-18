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

ip link set dev aws down >/dev/null 2>/dev/null
ip link del aws >/dev/null 2>/dev/null

ip link add aws type gretap local $PLUTO_ME remote $PLUTO_PEER
ip link set dev aws up
ip link set aws address 22:22:22:fa:ca:de
ip link set dev aws mtu 1360
