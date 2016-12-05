# daily_summary.rb - Finds and outputs all of the Issues added to Dradis in the past 24 hours
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

def with_scope(project, &block)
  Node.set_project_scope(project.id)
  Issue.set_project_scope(project.id)
  yield
end

puts; puts; puts

yest = DateTime.now - (1)
puts "### Summary of new Issues added to Dradis in the past 24 hours ###"
puts "Between #{yest} and #{DateTime.now}"
puts; puts

recent_projects  = Project.where("projects.updated_at >= ? AND projects.updated_at <= ?", yest, DateTime.now)
recent_projects.each do |project|
  with_scope(project) do
    issue_library = Node.issue_library
    Issue.where(node_id: issue_library.id).where("notes.updated_at >= ? AND notes.updated_at <= ?", yest, DateTime.now).each do |issue|
    		puts "* Recent Issue: '#{issue.title}'"
    		puts "  Added to Project: '#{project.name}' on '#{issue.updated_at}' "
    		puts " "
    end
  end
end
