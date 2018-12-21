# update_attachment_paths.rb - Updates attachment paths so they match the >= 3.0
#                              format (after one project per tab was introduced)
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

def update_attachment_paths(item, text_attr)
  attachment_url_regex = %r{!/pro/nodes/(\d+)/attachments/(.+)!}

  return false unless attachment_url_regex =~ item.send(text_attr)

  project_id = item.try(:project).try(:id) || item.node.project.id
  new_text = item.send(text_attr).gsub(attachment_url_regex) do |_|
    '!/pro/projects/%d/nodes/%d/attachments/%s!' % [project_id, $1, $2]
  end

  item.update_column(text_attr, new_text)

  true
end

items_to_check = {
  notes: 'text',
  evidence: 'content',
  content_blocks: 'content'
}

Project.all.each do |project|
  puts '-------------'
  puts "Checking project '#{project.name}' for old attachment urls..."

  items_to_check.each do |item_name, text_attr|
    count = 0
    project.send(item_name).each do |item|
      count += 1 if update_attachment_paths(item, text_attr)
    end
    puts "Updated #{count} #{item_name}"
  end

  # there is no `projects.cards`, so...
  count = 0
  project.boards.each do |board|
    board.cards.each do |card|
      count += 1 if update_attachment_paths(card, 'description')
    end
  end
  puts "Updated #{count} cards"
end
