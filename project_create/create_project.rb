# create_project.rb - Create a new Project and returns the assign ID.
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

if ARGV.size != 2
  puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} \"<project name>\" <owner_id>"
  exit 1
end

project = Project.new name: ARGV[0]
user_id = ARGV[1]

if project.save
  project = Project.last
  project.assign_owner(User.find_by_id(user_id) || User.first)
  puts project.id
  exit 0
else
  puts project.errors.full_messages.join("\n")
  exit 2
end
