#!/bin/bash

cp -R data/* "${cw_ROOT}"

sed -e "s,_cw_ROOT_,${cw_ROOT},g" \
    init/systemd/clusterware-flockd.service \
    > /etc/systemd/system/clusterware-flockd.service
