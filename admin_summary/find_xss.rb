# find_xss.rb - Find projects with XSS Issues in them.
#
# Copyright (C) 2016 Security Roots Ltd.
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
  puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <days ago>"
  exit 1
end

puts; puts; puts

days_ago = (ARGV.size == 1 ?  ARGV[0].to_i : 5).days.ago

Project.where('projects.updated_at >= ?', days_ago).each do |project|
  project.issues.each do |issue|
    if issue.title =~ /XSS/i
      puts "* Project #{project.name} has '#{issue.title}'"
      break
    end
  end
end
