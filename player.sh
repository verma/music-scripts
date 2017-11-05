#!/bin/bash

TARGET_HOST="$MPD_MUSIC_HOST"
CONTROL_SOCKET=/tmp/player-control-socket
EXITING=

if [[ "$TARGET_HOST" = "" ]] ; then
    echo "Your environment variable for MPD_MUSIC_HOST is not set."
    exit 1
fi

function stop-tunnel {
    if [ -e "$CONTROL_SOCKET" ] ; then
        echo ":: closing tunnels..."
        ssh -S $CONTROL_SOCKET -O exit $TARGET_HOST
    fi
}

function start-tunnels {
    if [ ! -e "$CONTROL_SOCKET" ] ; then
        echo ":: starting tunnels ..."
        ssh -M -A -S $CONTROL_SOCKET  -fnNT -L6600:localhost:6600 -L28000:localhost:8000 root@$TARGET_HOST -i ~/.ssh/id.ssh
    fi
}

function player {
    while [ -e "$CONTROL_SOCKET" ] ; do
	mpg123 "http://localhost:28000/mpd.mp3" >/dev/null 2>&1
	sleep 1
    done
}

trap stop-tunnel SIGINT SIGTERM


start-tunnels
player &

ncmpcpp
stop-tunnel
