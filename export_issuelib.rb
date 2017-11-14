# update_entries.rb - Exports all your IssueLibrary entries to a single file.
#
# Copyright (C) 2017 Security Roots Ltd.
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
# USAGE: scp the file to /tmp/, then run the following as dradispro:
# $ cd /tmp/
# $ RAILS_ENV=production bundle exec rails runner /tmp/export_issuelib.rb >> issuelib_dump.rb
# 
# This will create /tmp/issuelib_dump.rb, edit that as needed! 
# 
# Then, you can upload the issuelib_dump.rb file to your instance by running: 
# $ RAILS_ENV=production bundle exec rails runner /tmp/issuelib_dump.rb

Dradis::Pro::Issuelib::Entry.find do |libentry|
	line_breaks = libentry.content.dup
	line_breaks.gsub
	puts %{Dradis::Pro::Issuelib::Entry.create content: "#{libentry.content}"}
end
