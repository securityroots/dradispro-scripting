# find_xss.rb - Find projects with XSS Issues in them.
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
  Note.set_project_scope(project.id)
  Issue.set_project_scope(project.id)
  Evidence.set_project_scope(project.id)
  Tag.set_project_scope(project.id)
  yield
end

puts; puts; puts

days_ago = if ARGV.size == 1
             ARGV[0].to_i
           else
             5
           end.days.ago

recent_projects  = Project.where('projects.updated_at >= ?', days_ago)
recent_projects.each do |project|
  with_scope(project) do
    issue_library = Node.issue_library
    Issue.where(node_id: issue_library.id).each do |issue|
      if issue.title =~ /XSS/i
        puts "* Project #{project.name} has '#{issue.title}'"
        break
      end
    end
  end
end
