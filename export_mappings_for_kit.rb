# export_mappings_for_kit.rb - Export the Mapping and MappingFields to the kit format.
# for more on kits and configuring the Mappings Manager: 
# https://dradisframework.com/support/guides/administration/kits.html#plugins
# 
# Copyright (C) 2024 Security Roots Ltd.
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
 puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <report_template_filename>"
 exit 1
end

report_template = ARGV[0]
rtp = ReportTemplateProperties.find_by(title: report_template)
id = "rtp_#{rtp.id}"
puts "rtp = ReportTemplateProperties.find_by(title: '#{report_template}')"

mapping_count = 1

Mapping.where(destination: id).each do |mapping|
  puts "mapping#{mapping_count} = Mapping.create("
  puts "  component: '#{mapping.component}',"
  puts "  source: '#{mapping.source}',"
  puts "  destination: '#{mapping.destination}'"
  puts ")"
  puts "\n"
  
  MappingField.where(mapping_id: mapping.id).each do |field|
    puts "MappingField.create("
    puts "  mapping_id: #{mapping.id},"
    puts "  source_field: '#{field.source_field}',"
    puts "  destination_field: '#{field.destination_field}',"
    puts "  content: '#{field.content}'"
    puts ")"
    puts "\n"
  end
  mapping_count += 1
end
