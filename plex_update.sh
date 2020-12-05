#!/bin/bash

# @source @martinorob https://github.com/martinorob/plexupdate
# @author @loicdugay https://github.com/loicdugay
# Instruction sur https://github.com/loicdugay/synology-plex-auto-update

mkdir -p /tmp/plex/ > /dev/null 2>&1
token=$(cat /volume1/Plex/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
url=$(echo "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=$token")
jq=$(curl -s ${url})
newversion=$(echo $jq | jq -r .nas.Synology.version)
echo Version disponible : $newversion
curversion=$(synopkg version "Plex Media Server")
echo Version installée :    $curversion
if [ "$newversion" != "$curversion" ]
then
echo Nouvelle version disponible, installation en cours :
/usr/syno/bin/synonotify PKGHasUpgrade '{"[%HOSTNAME%]": $(hostname), "[%OSNAME%]": "Synology", "[%PKG_HAS_UPDATE%]": "Plex", "[%COMPANY_NAME%]": "Synology"}'
CPU=$(uname -m)
url=$(echo "${jq}" | jq -r '.nas.Synology.releases[] | select(.build=="linux-'"${CPU}"'") | .url')
/bin/wget $url -P /tmp/plex/
/usr/syno/bin/synopkg install /tmp/plex/*.spk
sleep 30
/usr/syno/bin/synopkg start "Plex Media Server"
rm -rf /tmp/plex/*
synoshare --setuser Plex NA = @*YOUR_UNAUTHORIZED_USERS_GROUP* >/dev/null
synoshare --setuser Plex RW = @*YOUR_AUTHORIZED_USERS_GROUP*,@video >/dev/null
else
echo Pas de nouvelle version à installer.
fi
exit
