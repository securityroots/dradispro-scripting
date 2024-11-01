# load_project_from_api.rb - Query a JSON API endpoint to gather Client and
# Project name and create matching Client and Project objects in Dradis.
#
# The script assums that the JSON API response is of the form:
#   [
#     {
#       "client": "Kobol Consulting",
#       "name": "Annual PCI assessment"
#     },
#     {
#       "client": "12Colonies Ltd",
#       "name": "Early Warning System code review"
#     }
#     ...
#   ]
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

require 'open-uri'

projects_endpoint = 'http://localhost:8000/api/projects'

puts "Loading projects from remote server..."

projects = JSON.load(open(projects_endpoint))
puts projects


projects.each do |project|
  puts "Adding #{project['client']}: #{project['name']}"
  client  = Client.find_or_create_by_name(project['client'])
  project = client.projects.create name: project['name']
end

puts "Done."
