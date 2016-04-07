# create_project.rb - Create a new Project and returns the assign ID.
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
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

if ARGV.size != 1
  puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <project name>"
  exit 1
end

project = Project.new name: ARGV[0]

if project.save
  project = Project.last
  puts project.id
  exit 0
else
  puts project.errors.full_messages.join("\n")
  exit 2
end
