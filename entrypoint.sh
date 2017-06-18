#!/usr/bin/dumb-init /bin/sh

case $1 in
    "aws")
        shift
        exec ./aws.sh "$@"
        ;;
    "peer")
        shift
        exec ./peer.sh "$@"
        ;;
    *)
        echo "aws or peer?"
        exit 2
        ;;
esac


