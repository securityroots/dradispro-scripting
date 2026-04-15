# issuelib_usage_report.rb - Returns a list of projects associated with each IssueLibrary entry. 
# Entries without associated projects are skipped.
#
# Copyright (C) 2026 Security Roots Ltd.
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
entries = Dradis::Pro::Plugins::Issuelib::Entry
            .includes(issues: { node: :project })
            .order(:id)

entries.each do |entry|
  projects = entry.issues.map { |issue| issue.node.project }.uniq.sort_by(&:name)
  next if projects.empty?

  puts "Entry ##{entry.id}: #{entry.title}"
  projects.each { |project| puts "  - [#{project.id}] #{project.name}" }
  puts
end
