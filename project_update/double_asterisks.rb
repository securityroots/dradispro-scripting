# double_asterisks.rb - Replaces double asterisks (**) from Issues, Evidence, and Content Blocks
# without removing nested lists
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
project  = Project.find(pid)

project.content_blocks.each do |block|
  block.content.gsub!(/\*\*(.*?)\*\*/) { "\*#{$1}\*" }
  block.save
end

project.issues.each do |issue|
  issue.content.gsub!(/\*\*(.*?)\*\*/) { "\*#{$1}\*" }
  issue.save
  issue.evidence.each do |e|
    e.content.gsub!(/\*\*(.*?)\*\*/) { "\*#{$1}\*" }
    e.save
  end
end

