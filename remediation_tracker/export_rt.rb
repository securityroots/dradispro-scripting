# export_rt.rb - Exports all your Remediation Tracker tickets to a single file.
#
# Copyright (C) 2020 Security Roots Ltd.
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
# $ RAILS_ENV=production bundle exec rails runner /opt/dradispro/dradispro/current/export_rt.rb >> rt_dump.txt
# 
# This will create /opt/dradispro/dradispro/current/rt_dump.txt, edit that as needed! 
# 

Dradis::Pro::Plugins::Remediationtracker::Ticket.find do |ticket|
	puts "Ticket: '#{ticket.title}'"
	puts "Due: '#{ticket.due_at}'"
	puts "Last updated: '#{ticket.updated_at}'"
	puts "Created: '#{ticket.created_at}'"
	puts "Category: '#{ticket.category_id}'"
	puts "State: '#{ticket.state_id}'"
	puts "Owner: '#{ticket.owner_id}'"
	puts "Assignee: '#{ticket.assignee_id}'"
	puts "Description: '#{ticket.description}'"
	puts
	puts "============"
	puts
end
