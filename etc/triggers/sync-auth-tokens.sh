#!/bin/bash
echo "---"
users=($(compgen -u))
for u in "${users[@]}"; do
  h="$(eval echo ~$u)"
  tokenf=$h/.config/flock/token
  if [ -f "${tokenf}" ]; then
    uid=$(id -u "${u}")
    token=$(cat "${tokenf}")
    echo "auth.$uid: $token"
  fi
done

