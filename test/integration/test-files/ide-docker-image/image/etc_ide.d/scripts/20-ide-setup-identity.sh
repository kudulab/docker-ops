#!/bin/bash -e

###########################################################################
# This file ensures files are mapped from ide_identity into ide_home.
# Fails if any required secret or configuration file is missing.
###########################################################################

# obligatory directory, copy it with all the secrets, particulary id_rsa
if [ ! -d "${ide_identity}/.ssh" ]; then
  echo "${ide_identity}/.ssh does not exist"
  exit 1;
fi
if [ ! -f "${ide_identity}/.ssh/id_rsa" ]; then
  echo "${ide_identity}/.ssh/id_rsa does not exist"
  exit 1;
fi
cp -r "${ide_identity}/.ssh" "${ide_home}"
for id_rsa_file in "${ide_home}/.ssh/"*"id_rsa"; do
  chown ide:ide "${id_rsa_file}"
  chmod 0600 "${id_rsa_file}"
done

# we need to ensure that ${ide_home}/.ssh/config contains at least:
# StrictHostKeyChecking no
echo "StrictHostKeyChecking no
UserKnownHostsFile /dev/null

ForwardAgent yes
Host git.ai-traders.com
User git
Port 2222
IdentityFile ${ide_home}/.ssh/id_rsa

Host gitlab.ai-traders.com
User git
Port 2222
IdentityFile ${ide_home}/.ssh/id_rsa
" > "${ide_home}/.ssh/config"

# not obligatory configuration file
if [ -f "${ide_identity}/.gitconfig" ]; then
  cp "${ide_identity}/.gitconfig" "${ide_home}"
fi

# Not obligatory file; in order to ensure that after bash login, the ide user
# is in /ide/work. Not obligatory but shortens end user's commands.
# Do not copy it from $ide_identity, because it may reference sth not installed in
# this docker image.
touch "${ide_home}/.profile"
echo "cd ${ide_work}" > "${ide_home}/.profile"
