# export_kit_config.rb - Export the mappings and RTPs for kit format
# for more on kits: https://dradisframework.com/support/guides/administration/kits.html
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
  puts "To export to another rb file, run the following"
  puts "RAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <report_template_filename> >> config.rb"
  exit 1
end

report_template = ARGV[0]
rtp = ReportTemplateProperties.find_by(title: report_template)
# Outputs the report template properties in the format used by the kit's rb file
puts "ReportTemplateProperties.create_from_hash!("
puts "  definition_file: File.basename(#{report_template}, '.rb'),"
puts "  # plugin_name: 'excel',"
puts "  plugin_name: 'word',"
puts "  # plugin_name: 'html_export',"
puts "  content_block_fields: {"
rtp.content_blocks.each do |block|
  puts "    '#{block[0]}' => ["
  block.drop(1).each do |field_list|
    field_list.each do |field|
      if field.values.nil?
        puts "      {name: '#{field.name}', type: '#{field.type}', values: nil},"
      else
        puts "      {name: '#{field.name}', type: '#{field.type}', values: #{field.values.join}},"
      end
      
    end
  end
  puts "    ],"
end
puts "  },"
puts "  document_properties: #{rtp.document_properties},"
puts "  evidence_fields: ["
rtp.evidence_fields.each do |evidence_field|
  if evidence_field.values == nil
    puts "nil"
  end
  puts "    {name: '#{evidence_field.name}', type: '#{evidence_field.type}', values: #{evidence_field.values.nil? ? 'nil' : evidence_field.values.join}},"
end
puts "  ],"
puts "  issue_fields: ["
rtp.issue_fields.each do |issue_field|
  puts "    {name: '#{issue_field.name}', type: '#{issue_field.type}', values: #{issue_field.values.nil? ? 'nil' : issue_field.values.join}},"
end

puts "  ]"
puts ")"
puts "################# Need values to a list, not an array"
puts "\n\n\n\n"

# Outputs the mappings in the format used by mappings_seed.rb
id = "rtp_#{rtp.id}"
puts "rtp = ReportTemplateProperties.find_by(title: '#{report_template}')"
mapping_count = 1
Mapping.where(destination: id).each do |mapping|
  #puts "mapping#{mapping_count} = Mapping.create("
  #puts "  component: '#{mapping.component}',"
  #puts "  source: '#{mapping.source}',"
  #puts "  destination: '#{mapping.destination}'"
  #puts ")"
  #puts "\n"
  MappingField.where(mapping_id: mapping.id).each do |field|
    #puts "MappingField.create("
    #puts "  mapping_id: #{mapping.id},"
    #puts "  source_field: '#{field.source_field}',"
    #puts "  destination_field: '#{field.destination_field}',"
    #puts "  content: \"#{field.content}\""
    #puts ")"
    #puts "\n"
  end
  mapping_count += 1
end
