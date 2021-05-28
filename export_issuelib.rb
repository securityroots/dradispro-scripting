# export_issuelib.rb - Exports all your IssueLibrary entries to a single file.
#
# Copyright (C) 2021 Security Roots Ltd.
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
#
# USAGE: scp the file to /opt/dradispro/dradispro/current/, then run the following as dradispro:
# $ cd /opt/dradispro/dradispro/current/
# $ RAILS_ENV=production bundle exec rails runner /opt/dradispro/dradispro/current/export_issuelib.rb >> issuelib_dump.rb
# 
# This will create /opt/dradispro/dradispro/current/issuelib_dump.rb, edit that as needed! 
# 
# Then, you can upload the issuelib_dump.rb file to your instance by running: 
# $ RAILS_ENV=production bundle exec rails runner /opt/dradispro/dradispro/current/issuelib_dump.rb

Dradis::Pro::Plugins::Issuelib::Entry.find do |libentry|
	puts %{Dradis::Pro::Plugins::Issuelib::Entry.create content: "#{libentry.content}"}
end
