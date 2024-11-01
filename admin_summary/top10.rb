# top10.rb - Creates a table of Top 10 Ports, 
# a table with Top 10 Services, and a table of Top OS for the project
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
 puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <project_id>"
 exit 1
end

pid = ARGV[0]
project = Project.find(pid)

os_all = []
ports_all = []
services_all = []

project.nodes.where(type_id: 1).each do |node|
  node.properties.each do |key, value|
    if key == "os"
      os_all << value
    elsif key == "services"
      value.each do |subhash|
        port_string = ""
        subhash.each do |k, v|
          if k == "port"
            port_string << "#{v}"
          elsif k == "protocol"
            port_string << "/#{v}"
          elsif k == "name"
            services_all << v
          end
        end
        ports_all << port_string
      end
    end
  end
end

ports_counts = ports_all.group_by{|i| i}.map{|k,v| [k, v.count] }.sort_by{|k,v| v}.reverse
ports_table = "|_.TOP 10 PORTS|_.COUNT|\r\n"
if ports_counts.count > 9 then
  ports_counts = ports_counts.first(10)
end
ports_counts.each do |k, v|
  ports_table << "|#{k}|#{v}|\r\n"
end

services_counts = services_all.group_by{|i| i}.map{|k,v| [k, v.count] }.sort_by{|k,v| v}.reverse
services_table = "|_.TOP 10 SERVICES|_.COUNT|\r\n"
if services_counts.count > 9 then
  services_counts = services_counts.first(10)
end
services_counts.each do |k, v|
  services_table << "|#{k}|#{v}|\r\n"
end

os_counts = os_all.group_by{|i| i}.map{|k,v| [k, v.count] }.sort_by{|k,v| v}.reverse
os_table = "|_.TOP OPERATING SYSTEMS|_.COUNT|\r\n"
if os_counts.count > 9 then
  os_counts = os_counts.first(10)
end
os_counts.each do |k, v|
  os_table << "|#{k}|#{v}|\r\n"
end

project.content_blocks.each do |block|
  if block.fields['Type'] == "Top10"
    block.set_field('PortScanning', ports_table)
    puts "Port Scanning table updated!"
    block.set_field('ServiceEnumeration', services_table)
    puts "Service Enumeration table updated!"
    block.set_field('OSEnumeration', os_table)
    puts "OS Enumeration table updated!"
    block.save
  end
end
