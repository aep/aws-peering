#!/bin/sh
fail() {
    echo "$@"
    exit 3
}

#this is used by the updownscript, because strongswan voids its output
ln -sf /proc/$$/fd/2 /var/log/dlog

[ -z "$SECRET" ]     && fail "missing -e 'SECRET=much long secret wow such secure'"
[ -z "$PEER"  ]      && fail "missing -e 'PEER=1.2.3.4'"


echo "peering : PSK \"$SECRET\"" > /etc/ipsec.secrets

cat - > /etc/strongswan.d/charonasroot.conf << EOF
charon {
    user  = root
    group = root
}
EOF

cat - > /etc/ipsec.conf << EOF
config setup
    charondebug=all

conn peer
    keyexchange=ikev2
    forceencaps=yes
    authby=secret
    auto=start
    left=%defaultroute
    leftid=peering
    right=$PEER
    type=transport
    leftupdown=/updown-peer.sh
EOF

exec ipsec start --nofork

