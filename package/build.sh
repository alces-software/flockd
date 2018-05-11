#!/bin/bash

package_name='flockd'

cw_ROOT="${cw_ROOT:-/opt/clusterware}"
PATH="${cw_ROOT}"/opt/git/bin:"${cw_ROOT}"/opt/ruby/bin:$PATH

if [ -f ./${package_name}.zip ]; then
  echo "Replacing existing ${package_name}.zip in this directory"
  rm ./${package_name}.zip
fi

temp_dir=$(mktemp -d /tmp/${package_name}-build-XXXXX)

cp -r * "${temp_dir}"
mkdir -p "${temp_dir}"/data/opt/flockd

echo "Creating Forge package of Flockd from git rev $(git rev-parse --short HEAD)"

pushd .. > /dev/null
git archive HEAD | tar -x -C "${temp_dir}"/data/opt/flockd
popd > /dev/null

pushd "${temp_dir}"/data/opt/flockd > /dev/null
bundle install --without="development test" --path=vendor

rm -rf vendor/cache .gitignore package
rm -rf vendor/ruby/2.2.0/bundler/gems/extensions \
  vendor/ruby/2.2.0/cache
popd

pushd "${temp_dir}" > /dev/null
zip -r ${package_name}.zip *
popd > /dev/null

mv "${temp_dir}"/${package_name}.zip .

rm -rf "${temp_dir}"
