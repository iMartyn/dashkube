#!/bin/bash

if [ ! -f "$MAC_URL_CSV" ]; then
  echo MAC_URL_CSV must be set in env and must exist
  exit 1
fi

declare -A LASTSEEN
DEBOUNCE_SECONDS=3

INTERFACE=$(ifconfig | cut -f1 -d' ' | grep -v 'weave\|veth\|vxlan\|lo\|datapath\|docker' | tr -d '\n')

mkfifo tcpdump_out
tcpdump -v -i $INTERFACE -n port 67 and port 68 -l -A > tcpdump_out & #| \

while IFS='' read -r line || [[ -n "$line" ]]; do
  if echo $line | grep 'Client-Ethernet-Address' > /dev/null 2>&1; then
    MAC=$(echo $line | grep 'Client-Ethernet-Address' | sed s/'.*Client-Ethernet-Address '//)
    MAC_NO_COLONS=$(echo $MAC | sed s/://g)
    if [ "${LASTSEEN[$MAC_NO_COLONS]}" == "" ]; then
      #first sight of this mac
      LASTSEEN[$MAC_NO_COLONS]=0
    fi
    URL=$(grep "^$MAC,http" $MAC_URL_CSV | sed "s/^$MAC,//")
    if [ ! "$URL" == "" ]; then
      if [ $(expr ${LASTSEEN[$MAC_NO_COLONS]} + $DEBOUNCE_SECONDS) -gt $(date +%s) ]; then
        echo "$MAC seen in last $DEBOUNCE_SECONDS seconds, ignoring"
      else
        LASTSEEN[$MAC_NO_COLONS]=$(date +%s)
        echo "$MAC seen, curling $URL"
        curl "$URL" > /dev/null
      fi
    else
      echo "$MAC seen but no url found."
    fi
  fi
done < tcpdump_out
rm tcptump_out
exit 1 # We exit(1) to make kube restart us if we die.

