#!/bin/bash
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
    type=$(jq -r .type <<< "$export")
    scope=$(jq -r .scope <<< "$export")
    source=$(jq -r .source <<< "$export")
    if [ "${scope}" == "system" ]; then
        echo "# mount -t nfs $source /mnt/flock/local/${a}"
    fi
  done
done
