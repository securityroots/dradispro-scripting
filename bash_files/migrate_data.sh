#!/bin/bash

# migrate_data.sh - allows you to migrate data from one Dradis instance to another.
# To use: Run this script on a machine that has SSH access to both your old and
# new Dradis instances. If you do not have SSH keys set up, you will be prompted
# for your SSH passwords multiple times.
#
# Copyright (C) 2024 Security Roots Ltd.
#
# This file is part of the Dradis Pro Scripting Examples (DPSE) collection.
# The collection can be found at
#   https://github.com/securityroots/dradispro-scripting
#
# DPSE free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# DPSE is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DPSE.  If not, see <http://www.gnu.org/licenses/>.

echo This script assumes you have access by SSH to both your old Dradis VM and your new Dradis VM. Backup files will be stored on the machine from which you run this script, in the directory from which it is run.
echo
echo If you do not have SSH keys set up on your Dradis instances, you will be prompted multiple times per machine for your password. You can set up passwordless SSH using SSH keys using this guide: https://www.debian.org/devel/passwordlessssh
echo
echo Let\'s get started!
echo
echo What is the address of your old Dradis VM? E.g. 192.168.0.110
read old_ip
echo What is the address of your new Dradis VM? E.g. 192.168.0.111
read new_ip

# Migrate attachments
echo Migrating attachments...
ssh dradispro@$old_ip -- 'dp-export-attachments' > dradis-attachments.tar
cat dradis-attachments.tar | ssh dradispro@$new_ip -- 'dp-import-attachments'

echo Attachments migration step completed.

# Migrate DB
echo Migrating database...
ssh dradispro@$old_ip -- 'dp-export-mysql' > dradis-mysql-backup.sql

# Check for first line that will create errors, and remove if present
read -r firstline < dradis-mysql-backup.sql
if [[ $firstline = *"- enable the sandbox mode "* ]]; then
sed -i '1d' dradis-mysql-backup.sql
fi

cat dradis-mysql-backup.sql | ssh dradispro@$new_ip -- 'dp-import-mysql'

echo Database migration step completed.

# Migrate templates
echo Migrating templates...
ssh dradispro@$old_ip -- 'dp-export-templates' > dradis-templates.tar
cat dradis-templates.tar | ssh dradispro@$new_ip -- 'dp-import-templates'

echo Templates migration step completed.

# Migrate Gateway themes
# To do this we inspect if the Gateway is actually installed on the old machine.
# We do that by SCP-ing Gemfile.plugins to the local machine to inspect it.
# If not, no migration is done. The local Gemfile.plugins is deleted afterwards.
echo Checking for Gateway...
scp dradispro@$old_ip:/opt/dradispro/dradispro/current/Gemfile.plugins ./Gemfile.plugins
filename="Gemfile.plugins"

while read -r line
do
  id=$(cut -c 6-22 <<< "$line")
  if [[ $id = "dradispro-gateway" ]]; then
    echo Gateway found.
    echo Migrating Gateway themes...
    ssh dradispro@$old_ip -- 'dp-export-themes' > dradis-themes.tar
    cat dradis-themes.tar | ssh dradispro@$new_ip -- 'dp-import-themes'
  fi
done < $filename 
rm $filename

echo Gateway themes migration step completed.

# Export storage; not yet implemented
# echo Migrating storage...
# ssh dradispro@$old_ip -- 'dp-export-storage' > dradis-storage.tar
# cat dradis-storage.tar | ssh dradispro@$new_ip -- 'dp-import-storage'
# echo Storage migration completed.

# Migrate, and restart processes
echo Restarting worker processes on your new Dradis instance...
ssh dradispro@$new_ip "cd /opt/dradispro/dradispro/current/;RAILS_ENV=production /opt/rbenv/shims/bundle exec rails db:migrate;god restart; god load /etc/god.d/dradispro-puma.god"

echo Processes restarted.
echo
echo Done!
