#!/bin/bash -e
unset BUNDLE_PATH
unset BUNDLE_BIN

# sh -c "sudo chown -R vets-api /srv/vets-api/src"

# note this logic is duplicated in the Dockerfile for prod builds,
# if you make major alteration here, please check that usage as well
id
whoami
chown -R 939 /srv/vets-api
bundle check || bundle install --binstubs="${BUNDLE_APP_CONFIG}/bin"

exec "$@"

if [ -e  "./docker_debugging" ] ; then
  echo starting rake docker_debugging:setup
  rake docker_debugging:setup
fi

