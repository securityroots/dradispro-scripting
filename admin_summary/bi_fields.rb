# bi_fields.rb - Return your Custom Project Properties from the BI Dashboard
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

if ARGV.size != 1
 puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <project_id>"
 exit 1
end

pid = ARGV[0]

Project.find(pid).custom_field_values.each do |project_property|
	bi_field_id = project_property.custom_field_id
	bi_field_name = Dradis::Pro::BI::CustomField.find(bi_field_id).name
	puts "#{bi_field_name}: #{project_property.value}"
end

# To update the fields in all projects or just fields that may or may not be blank:
Project.all.each do |project|
  custom_field_value = Dradis::Pro::BI::CustomFieldValue.where(fieldable: project, custom_field_id: Dradis::Pro::BI::CustomField.find_by_name('Project Type')).first_or_initialize
  custom_field_value.value = 'I have been updated'
  custom_field_value.save
end
