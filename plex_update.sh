#!/bin/bash

# Author @loicdugay https://github.com/loicdugay
# Instruction sur https://github.com/loicdugay/synology-plex-auto-update
#
# Merci à
# @mj0nsplex https://forums.plex.tv/u/j0nsplex
# @martinorob https://github.com/martinorob/plexupdate
# @michealespinola https://github.com/michealespinola/syno.plexupdate

# Vérification ROOT
if [ "$EUID" -ne "0" ];
  then
    printf " %s\n" "Ce script DOIT être exécuté avec les persmissions root."
    /usr/syno/bin/synonotify PKGHasUpgrade '{"%PKG_HAS_UPDATE%": "Le script de mise à jour automatique de Plex Media Server a échoué.\n\nCe script DOIT être exécuté avec les persmissions root."}'
    printf "\n"
    exit 1
fi

# Vérification de la version de DSM
DSMVersion=$(cat /etc.defaults/VERSION | grep -i 'majorversion=' | cut -d"\"" -f 2)
/usr/bin/dpkg --compare-versions 7 gt "$DSMVersion"
if [ "$?" -eq "0" ];
  then
    printf " %s\n" "Ce script nécessite DSM 7 pour être installé."
    /usr/syno/bin/synonotify PKGHasUpgrade '{"%PKG_HAS_UPDATE%": "Le script de mise à jour automatique de Plex Media Server a échoué.\n\nCe script nécessite DSM 7 pour être installé."}'
    printf "\n"
    exit 1
fi

# Recherche de la version de Plex Media Server
curversion=$(synopkg version "PlexMediaServer")
curversion=$(echo $curversion | grep -oP '^.+?(?=\-)')
splitversion1=$(echo $curversion | cut -d "." -f 1 )
splitversion2=$(echo $curversion | cut -d "." -f 2 )
splitversion3=$(echo $curversion | cut -d "." -f 3 )
splitversion4=$(echo $curversion | cut -d "." -f 4 )
newpath=false
if [ $splitversion1 -ge 1 ]
then
  if [ $splitversion2 -ge 24 ]
  then
    if [ $splitversion3 -ge 2 ]
    then
      if [ $splitversion4 -ge 4973 ]
      then
        newpath=true
      fi
    fi
  fi
fi
if [[ $newpath ]];
then
  echo Version de Plex supérieure à 1.24.2.4973 détectée
  token=$(cat /volume1/PlexMediaServer/AppData/Plex\ Media\ Server/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
  channel=$(cat /volume1/PlexMediaServer/AppData/Plex\ Media\ Server/Preferences.xml | grep -oP 'ButlerUpdateChannel="\K[^"]+')
else
  echo Version de Plex inférieure à 1.24.2.4973 détectée
  token=$(cat /volume1/@apphome/PlexMediaServer/Plex\ Media\ Server/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
  channel=$(cat /volume1/@apphome/PlexMediaServer/Plex\ Media\ Server/Preferences.xml | grep -oP 'ButlerUpdateChannel="\K[^"]+')
fi

if [ "$channel" -eq "8" ]; then
  url=$(echo "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=$token")
else
  url=$(echo "https://plex.tv/api/downloads/5.json")
fi
jq=$(curl -s ${url})
newversion=$(echo $jq | jq -r '.nas."Synology (DSM 7)".version')
newversion=$(echo $newversion | grep -oP '^.+?(?=\-)')

echo Version disponible : $newversion
echo Version installée : $curversion

if [ "$newversion" != "$curversion" ]
  then
    mkdir -p /tmp/plex/ > /dev/null 2>&1
    echo Nouvelle version disponible, installation en cours :
    CPU=$(uname -m)
    url=$(echo "${jq}" | jq -r '.nas."Synology (DSM 7)".releases[] | select(.build=="linux-'"${CPU}"'") | .url')
    /bin/wget $url -P /tmp/plex/
    /usr/syno/bin/synopkg install /tmp/plex/*.spk
    sleep 30
    /usr/syno/bin/synopkg start "PlexMediaServer"
    rm -rf /tmp/plex/*
    /usr/syno/bin/synonotify PKGHasUpgrade '{"%PKG_HAS_UPDATE%": "Le script de mise à jour automatique de Plex Media Server a installé la dernière version disponible."}'
  else
    echo Pas de nouvelle version à installer.
    /usr/syno/bin/synonotify PKGHasUpgrade '{"%PKG_HAS_UPDATE%": "Le script de mise à jour automatique de Plex Media Server ne détecte pas de nouvelle version à installer."}'
fi
exit
