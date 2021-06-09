# update_attachments_after_node_merge.rb - Find instances of attachments after merging nodes
#
# Copyright (C) 2021 Security Roots Ltd.
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
  puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <original_node_id> <new_node_id>"
  exit 1
end

original_node_id = ARGV[0]
new_node = Node.where(id: ARGV[1]).first

unless new_node
  puts "Cannot find node with ID: #{ARGV[1]}"
  exit 1
end

ATTACHMENTS_REGEX = /!(\/pro)?\/projects\/(\d+?)\/nodes\/#{original_node_id}\/attachments\/(.+?)!/

new_node.notes.each do |note|
  new_content = note.content.gsub(ATTACHMENTS_REGEX) do
    "!/pro/projects/#{$2}/nodes/#{new_node.id}/attachments/#{$3}!"
  end
  note.update_attribute :text, new_content

  puts "Replacing Note##{note.id}"
end

new_node.evidence.each do |evidence|
  new_content = evidence.content.gsub(ATTACHMENTS_REGEX) do
    "!/pro/projects/#{$2}/nodes/#{new_node.id}/attachments/#{$3}!"
  end
  evidence.update_attribute :content, new_content

  puts "Replacing Evidence##{evidence.id}"
end
