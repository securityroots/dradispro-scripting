# document_properties.rb - Return your Document Properties from the Report Content 
# page of your Dradis project and update them.
#
# Copyright (C) 2022 Security Roots Ltd.
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

project = Project.find(ARGV[0])


# When using 'set_property' if the property exists we append the new
# value to it and the property becomes an Array. This is not the desired
# result here, so we delete/clear the property first.
project.content_library.properties.delete("dradis.client")
project.content_library.set_property("dradis.client", 'Updated!')
project.content_library.save
puts "Updated the value for dradis.client"

puts "Listing properties for '#{project.name}' project..."
project.content_library.properties.each_pair do |key, value|
  puts "\t#{key}: #{value}"
end
puts "Done."
