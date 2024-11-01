# export_all_mappings.rb - Export the Mapping and MappingFields from all report template the kit format.
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
#
# USAGE: 
# scp the file to /opt/dradispro/dradispro/current/, then run the following as dradispro:
# $ cd /opt/dradispro/dradispro/current/
# $ RAILS_ENV=production bundle exec rails runner /opt/dradispro/dradispro/current/export_all_mappings.rb >> mappings_seed.rb
# 
# This will create /opt/dradispro/dradispro/current/mappings_seed.rb
# which can be used in your kits as needed https://dradisframework.com/support/guides/administration/kits.html#plugins

mapping_count = 1
ReportTemplateProperties.all.each do |rtp|
  id = "rtp_#{rtp.id}"
  if Mapping.where(destination: id).count > 0
    report_template = ReportTemplateProperties.find(rtp.id).title
    puts "rtp = ReportTemplateProperties.find_by(title: '#{report_template}')"

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
        puts "  content: \"#{field.content}\""
        puts ")"
        puts "\n"
      end
      mapping_count += 1
    end
    puts "\n"
  end
end
