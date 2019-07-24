# bulk_upload.sh - allows you to upload multiple tool output files at once.
# To use: scp your tool output files to a folder on your Dradis instance: <path>
# Don't mix multiple tools in a single folder.
# Note also that this script will also scan subfolders.
#
# scp this script file to /opt/dradispro/dradispro/current/ on your Dradis instance.
# $ chmod +x bulk_upload.sh
# $ ./nmap_bash.sh <project_id> <plugin> <path>
#
# Copyright (C) 2019 Security Roots Ltd.
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

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]; then
  echo "Usage: ./nmap_bash.sh <project_id> <plugin> <path>"
  echo ""
  echo "<project_id> is the number of your project. E.g. for IP [dradis IP]/pro/projects/4 your <project_id> is 4"
  echo ""
  echo "<plugin> is the plugin to upload, e.g. nmap, burp, or nessus. You can only use this script for one plugin at a time."
  echo ""
  echo "<path> is the path to the folder where you store the plugin output files to use, e.g. /tmp/nmap/"
  echo "Take care not to mix multiple plugins in the same folder, e.g. nmap and nessus results together, or the bulk upload will not work properly."
  echo "Note that this script will also scan subfolders of the <path> for XML files."
else
  for file in $3*.xml
  do
    PROJECT_ID=$1 RAILS_ENV=production bundle exec thor dradis:plugins:$2:upload $file
  done
fi
