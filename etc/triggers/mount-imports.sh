#!/bin/bash
_JQ="/opt/clusterware/opt/jq/bin/jq"
echo "clusters"
read clusters
echo "localcluster"
read localcluster
echo "# Found clusters: $clusters"
for c in $clusters; do
  if [ "$c" == "-" -o "$c" == "$localcluster" ]; then
      continue
  fi
  echo "get $c exports"
  read exports
  echo "# $c has exports: $exports"
  for a in $exports; do
    echo "get $c exports.$a"
    read export
    echo "# Export: $a is: $export"
    type=$($_JQ -r .type <<< "$export")
    scope=$($_JQ -r .scope <<< "$export")
    source=$($_JQ -r .source <<< "$export")
    if [ "${scope}" == "system" ]; then
        if ! grep -q /mnt/flock/targets/${c}/${a} /proc/mounts; then
            echo "# mount -t nfs $source /mnt/flock/targets/${c}/${a}"
            mkdir -p /mnt/flock/targets/${c}/${a}
            mount -t nfs $source /mnt/flock/targets/${c}/${a}
        else
          echo "# already mounted: /mnt/flock/targets/${c}/${a}"
        fi
    fi
  done
done
if [ ! -d /mnt/flock/users ]; then
    mkdir -p /mnt/flock/users
    chmod 1777 /mnt/flock/users
fi
