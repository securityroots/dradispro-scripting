# send_to_rt.rb - Sends all Issues in a given project to the Remediation Tracker as Tickets
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

if ARGV.size != 1
 puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <project_id>"
 exit 1
end

assignee_user = User.find_by_email("admin@securityroots.com")
owner_user = User.find_by_email("rachael@securityroots.com")

puts "Assignee: #{assignee_user.email}"
puts "Owner: #{owner_user.email}"

Project.find(ARGV[0]).issues.each do |issue|
  Dradis::Pro::Plugins::Remediationtracker::Ticket.create title: issue.title, description: issue.content, assignee: assignee_user, category_id: 1, owner: owner_user, state_id: 1
  puts "* Sent #{issue.title}"
end