#!/bin/bash
key=$1
old=$2
val=$3
mode=$4

uid=$(echo "$key" | cut -f2 -d'.')
el=$(echo "$key" | cut -f3 -d'.')
uname=$(id -un $uid)
home_dir="$(eval echo ~$uname)"

if [ "$el" == "sshkey" ]; then
    # if we're hub, replicate to all clusters
    # if we're not hub, if this is set mode, replicate to hub
    if [ "$mode" == "hub" -o "$mode" == "set" ]; then
        echo "replicate $key"
    else
      # else write the value
      if [ ! -f "$home_dir"/.ssh/authorized_keys ]; then
          touch "$home_dir"/.ssh/authorized_keys
          chown $uname "$home_dir"/.ssh/authorized_keys
          chmod 0600 "$home_dir"/.ssh/authorized_keys
      fi
      echo "$val" >> "$home_dir"/.ssh/authorized_keys
    fi
fi
