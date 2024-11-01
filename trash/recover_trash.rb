# recover_trash.rb - Restores all the items from the Trash feature in a single project
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
# USAGE: Update User and Project ID values in Lines 28 + 30
# scp the file to /opt/dradispro/dradispro/current/, then run the following as dradispro:
# $ cd /opt/dradispro/dradispro/current/
# $ RAILS_ENV=production bundle exec rails runner /opt/dradispro/dradispro/current/recover_trash.rb

# Update email before running
user    = User.find_by_email('admin@securityroots.com')
# Update project ID before running
project = Project.find(1)

trash = RecoverableRevision.all(project_id: project.id)
puts "recovering #{trash.count} items from trash"

trash.each do |item|
  if item.recover
    #track_recovered(item.object, User.find_by_email('admin@securityroots.com'))
    Activity.create!(
      trackable: item.object,
      user:      user,
      project:   project,
      action:    'recover'
    )
    puts "#{item.type} recovered"
  else
    puts "Can't recover #{item.type}: #{item.errors.full_messages.join(',')}"
  end
end