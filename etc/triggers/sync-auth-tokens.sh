#!/bin/bash
echo "---"
for a in /tmp/test/*/token; do # /users/*/.config/flock/token; do
  uid=$(gstat -c%u "$a")
  token=$(cat "$a")
  echo "auth.$uid: $token"
done
