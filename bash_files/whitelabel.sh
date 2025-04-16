#!/bin/bash

# whitelabel.sh - lets you update logos and icons on your Dradis Pro instance to
# white-label it with your company identity; particularly handy for the Gateway
#
# To use: Run this from a machine with SSH access to your Dradis instance. You
# will then transfer logo files and icons, and replace the company name and website.
#
# Copyright (C) 2025 Security Roots Ltd.
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

echo "This script will help you white-label Dradis with your company identity. As changes made with this script will not survive upgrades, you will need to re-run it after every Dradis upgrade."
echo
echo "Ensure you have SSH access to your Dradis instance from this machine."
echo "You will want to get your icon and favicon ready. You need a large, medium, and small icon, and a favicon showing a read and unread notification state."
echo
echo "Path names requested in this script should be relative. In other words, if your icon.png is in this folder, use: icon.png"
echo "Or if it's in a subfolder, use e.g.: dradis/icon.png. Give the filename and extension as well when asked for the images."
echo
echo "What is your SSH/SCP destination? Example: if your Dradis instance is hosted at 192.169.0.1, enter: 192.169.0.1"
read SSHDradis
echo "Note that if you access SSH with a password instead of a key, you will be prompted many times for your password. Key pairs are better ¯⁠\\⁠_⁠(⁠ツ⁠)⁠\\_⁠/⁠¯"
echo

# Get icon locations
echo "Where is your icon (large) file located? This file will be used as the logo on the login page."
read LargeIcon

echo "Where is your icon (medium) file located? This is used as the logo in the top left of the main Dradis interface."
read MediumIcon

echo "Where is your icon (small) file located? This is the small logo used inside Dradis projects."
read SmallIcon

echo "Where is your favicon (no notifications) file located?"
read FaviconRead

echo "Where is your favicon (unread/notifications present) file located?"
read FaviconUnread

scp ./$SmallIcon dradispro@$SSHDradis:/opt/dradispro/dradispro/current/app/assets/images/logo_small.png
scp ./$MediumIcon dradispro@$SSHDradis:/opt/dradispro/dradispro/current/app/assets/images/dradispro-logo.png
scp ./$LargeIcon dradispro@$SSHDradis:/opt/dradispro/dradispro/current/app/assets/images/logo_full_small.png

scp ./$FaviconRead dradispro@$SSHDradis:/opt/dradispro/dradispro/current/app/assets/images/favicon.ico
scp ./$FaviconUnread dradispro@$SSHDradis:/opt/dradispro/dradispro/current/app/assets/images/favicon-unread.ico

echo "Insert the company name you would like to use across the Dradis Web UI. Default: Dradis Professional Edition"
read LabelID

echo "What website would you like linked? e.g.: www.mycompany.com"
read SiteURI
DradisURI=dradis.com


# V4.15 of Dradis or older (Tylium and Mintcreek views)
ssh dradispro@$SSHDradis "sed -i \"s~Dradis Professional Edition~$LabelID~g\" /opt/dradispro/dradispro/current/app/views/layouts/application.html.erb"
ssh dradispro@$SSHDradis "sed -i \"s~$DradisURI~$SiteURI~g\" /opt/dradispro/dradispro/current/app/views/layouts/application.html.erb"
ssh dradispro@$SSHDradis "sed -i \"s~Dradis Professional Edition~$LabelID~g\" /opt/dradispro/dradispro/current/app/views/layouts/tylium.html.erb"
ssh dradispro@$SSHDradis "sed -i \"s~Dradis Professional Edition~$LabelID~g\" /opt/dradispro/dradispro/current/app/views/layouts/mintcreek.html.erb"
ssh dradispro@$SSHDradis "sed -i \"s~$DradisURI~$SiteURI~g\" /opt/dradispro/dradispro/current/app/views/layouts/mintcreek.html.erb"

# V4.16 of Dradis or newer (Hera view) UNTESTED!
# ssh dradispro@$SSHDradis "sed -i \"s~Dradis Professional Edition~$LabelID~g\" /opt/dradispro/dradispro/current/app/views/layouts/application.html.erb"
# ssh dradispro@$SSHDradis "sed -i \"s~$DradisURI~$SiteURI~g\" /opt/dradispro/dradispro/current/app/views/layouts/application.html.erb"
# ssh dradispro@$SSHDradis "sed -i \"s~Dradis Professional Edition~$LabelID~g\" /opt/dradispro/dradispro/current/app/helpers/hera_helper.rb"
# ssh dradispro@$SSHDradis "sed -i \"s~Dradis Professional Edition~$LabelID~g\" /opt/dradispro/dradispro/current/app/views/layouts/hera/footer/_pro.html.erb"

# Precompile and restart
ssh dradispro@$SSHDradis << EOF
cd /opt/dradispro/dradispro/current/
RAILS_ENV=production bundle exec rails assets:precompile
god restart
EOF

echo "Done! It's recommended that you hard-reboot your instance of Dradis to force it to pick up the new images and code."
