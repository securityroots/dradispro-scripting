# project_association_check.rb - Checks to make sure all projects are associated with a report template
#
# Copyright (C) 2018 Security Roots Ltd.
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
# USAGE: scp the file to /opt/dradispro/dradispro/current/, then run the following as dradispro:
# $ cd /opt/dradispro/dradispro/current/
# $ RAILS_ENV=production bundle exec rails runner /opt/dradispro/dradispro/current/project_association_check.rb

all_projects = Project.all
all_templates = ReportTemplateProperties.all

# Create an array with the IDs of all of the existing report templates on the instance
rtp_array = []
all_templates.each do |template|
	rtp_array << template.id
end

puts "## These projects are no longer associated with a report template! ##"
puts " "

# Check to see if each project is associated with an existing report template
all_projects.each do |project|
	rtp = project.report_template_properties_id
	unless rtp_array.include? rtp
		puts "#{project.name}"
		puts "    go to /pro/projects/#{project.id}/edit to resolve"
		puts " "		
	end
end
