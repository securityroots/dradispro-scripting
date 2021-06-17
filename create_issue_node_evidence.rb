# create_issue_node_evidence.rb - Create an Issue, create a Node, and then 
# create an instance of Evidence associated with both
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

pid = ARGV[0]
project  = Project.find(pid)

node = Node.create(project: project, label: "10.0.0.1")
node.save
puts "Node #{node.id} created"

issue = Issue.create(node: project.issue_library, text: "#[Title]#\r\nI am the Issue\r\n")
issue.save
puts "Issue '#{issue.title}' created"

evidence = Evidence.create(content: "#[Title]#\nEvidence1\n\n#[Description]#\nn/a\n\n#[Extra]#\nExtra field", issue: issue, node: node)
evidence.save
puts "Evidence #{evidence.id} created"
