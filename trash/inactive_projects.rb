# inactive_projects.rb - Archives projects inactive for 30+ days. Trashes projects archived for 30+ days.
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

INACTIVITY_DAYS = 30
ARCHIVE_DAYS    = 30

# -- Step 1: Archive inactive projects ----------------------------------------

inactivity_cutoff = INACTIVITY_DAYS.days.ago
inactive_projects = Project.unarchived.undiscarded.where('projects.updated_at < ?', inactivity_cutoff)

puts "Archiving projects with no activity in the last #{INACTIVITY_DAYS} days"
puts "(cutoff: #{inactivity_cutoff.to_date})"
puts

archived_count = 0

inactive_projects.each do |project|
  last_updated = project.updated_at
  project.archive
  archived_count += 1
  puts "  Archived [##{project.id}] #{project.name} (last updated #{last_updated.to_date})"
end

puts
puts "Done. Archived #{archived_count} project#{'s' if archived_count != 1}."
puts

# -- Step 2: Move stale archived projects to Trash ----------------------------

archive_cutoff = ARCHIVE_DAYS.days.ago
stale_projects = Project.archived.undiscarded.where('projects.archived_at < ?', archive_cutoff)

puts "Moving projects archived for more than #{ARCHIVE_DAYS} days to Trash"
puts "(cutoff: #{archive_cutoff.to_date})"
puts

trashed_count = 0

stale_projects.each do |project|
  project.discard
  trashed_count += 1
  puts "  Trashed [##{project.id}] #{project.name} (archived on #{project.archived_at.to_date})"
end

puts
puts "Done. Moved #{trashed_count} project#{'s' if trashed_count != 1} to Trash."
