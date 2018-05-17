#!/bin/bash
. /opt/clusterware/etc/flock.rc
cw_FLOCK_mnt=${cw_FLOCK_mnt:-/mnt/flight}
mkdir -p ${cw_FLOCK_mnt}
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
        if ! grep -q ${cw_FLOCK_mnt}/targets/${c}/${a} /proc/mounts; then
            echo "# mount -t nfs $source ${cw_FLOCK_mnt}/targets/${c}/${a}"
            mkdir -p ${cw_FLOCK_mnt}/targets/${c}/${a}
            mount -t nfs $source ${cw_FLOCK_mnt}/targets/${c}/${a}
        else
          echo "# already mounted: ${cw_FLOCK_mnt}/targets/${c}/${a}"
        fi
    fi
  done
done
if [ ! -d ${cw_FLOCK_mnt}/users ]; then
    mkdir -p ${cw_FLOCK_mnt}/users
    chmod 1777 ${cw_FLOCK_mnt}/users
fi
