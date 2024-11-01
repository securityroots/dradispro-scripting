# copy_mappings.rb - Copy all mappings from one report template to another
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

if ARGV.size != 2
 puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <source_report_template> <destination_report_template>"
 puts "Don't use the file extension. If your file is called dradis_welcome_template.v0.10.docx, use dradis_welcome_template.v0.10"
 exit 1
end

source_template = ARGV[0]
destination_template = ARGV[1]

source_rtp = ReportTemplateProperties.find_by(title: source_template)
destination_rtp = ReportTemplateProperties.find_by(title: destination_template)

# Duplicate the mappings to the new RTP
Mapping.where(destination: "rtp_#{source_rtp.id}").each do |mapping|
  copy = mapping.dup
  copy.update(destination: "rtp_#{destination_rtp.id}")
  mapping.mapping_fields.each do |mapping_field|
    mapping_field.dup.update(mapping_id: copy.id)
  end
end
