# replace_in_issues.rb - Replace strings in issue text on a specific project
#
# Copyright (C) 2016 Security Roots Ltd.
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

issuelib = Node.find_by(type_id: Node::Types::ISSUELIB, project_id: ARGV[0])
if issuelib.nil?
  puts "Could not find project with id #{ARGV[0]}"
  exit 2
end

issues   = Issue.where(node_id: issuelib.id)

issues.each do |issue|
  puts "Processing issue #{issue.title}..."
  # replace with custom changes
  issue.text.gsub!("an attacker", "a malicious actor")
  issue.text.gsub!("attackers", "malicious actors")
  issue.text.gsub!("attacker", "malicious actor")
  issue.save
end

puts "Done"
exit 0
