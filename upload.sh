#!/bin/bash
#

# Pull an audio file from youtube and upload it

if [[ "$MPD_MUSIC_HOST" = "" ]] ; then
    echo "Environment variable MPD_MUSIC_HOST is not set."
    exit 1
fi
    

FILE="$1"

if [[ "$FILE" == "" ]] ; then
    echo "No link specified."
    exit 1
fi

echo ":: attempting to pull $FILE ..."
youtube-dl "$FILE" -x --audio-format mp3 --audio-quality 320k

TARGET_FILE=$(ls *.mp3)

echo ":: target file is: $TARGET_FILE"

echo ":: checking and uploading files ..."
scp -i ~/.ssh/id.ssh *.mp3 root@"$MPD_HOST":/var/lib/mpd/music/

echo ":: notfyinf mpd to update ..."
mpc update
mpc add "$TARGET_FILE"

echo ":: cleaning up ..."
rm -f "$TARGET_FILE"

echo ":: done."
