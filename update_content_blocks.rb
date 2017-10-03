# delete_nodes_without_evidence.rb - Deltes Host Nodes that don't have any Evidence
#   associated with them in a specific project
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
project  = Project.find(pid)

Node.set_project_scope(project.id)
Issue.set_project_scope(project.id)
Evidence.set_project_scope(project.id)
Tag.set_project_scope(project.id)

#Node.where(type_id: 1).each do |n|
ContentBlock.where(project_id: project.id).each do |block|
    puts "#{block.content}"
    block.content << "Updated!"
    block.set_field('Title', "Bar")
    block.block_group = "Foo"
    block.save
    puts "#{block.block_group}"
end