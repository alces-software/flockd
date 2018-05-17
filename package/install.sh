#!/bin/bash

cp -R data/* "${cw_ROOT}"

sed -e "s,_cw_ROOT_,${cw_ROOT},g" \
    init/systemd/clusterware-flockd.service \
    > /etc/systemd/system/clusterware-flockd.service

cp "${cw_ROOT}"/opt/flockd/etc/values.yml.ex "${cw_ROOT}"/opt/flockd/etc/values.yml
chmod 0600 "${cw_ROOT}"/opt/flockd/etc/values.yml
chmod 0600 "${cw_ROOT}"/opt/flockd/etc/config.yml

echo ':log_file: /var/log/flockd/flockd.log' >> "${cw_ROOT}"/opt/flockd/etc/config.yml

mkdir -p /var/log/flockd
touch /var/log/flockd/flockd.log
chmod 0600 /var/log/flockd/flockd.log
