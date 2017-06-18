#!/bin/sh
fail() {
    echo "$@"
    exit 3
}

#this is used by the updownscript, because strongswan voids its output
ln -sf /proc/$$/fd/2 /var/log/dlog

[ -z "$SECRET" ]     && fail "missing -e 'SECRET=much long secret wow such secure'"

AWS_PUBLIC_IP=$(curl --fail -s http://169.254.169.254/latest/meta-data/public-ipv4)

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
    auto=add
    left=%defaultroute
    leftid=$AWS_PUBLIC_IP
    type=transport
    leftupdown=/updown-aws.sh
EOF

exec ipsec start --nofork

