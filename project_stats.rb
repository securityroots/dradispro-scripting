# project_stats.rb - Find Issues affecting multiple projects and other stats.
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

def underline(title, character = '=')
  puts title
  puts character * title.length
end

if ARGV.size != 1
  puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <days ago>"
  exit 1
end


days_ago = if ARGV.size == 1
             ARGV[0].to_i
           else
             5
           end.days.ago


# 1. Gather the metrics

project_data     = {}
issue_data       = {}

Project.where('projects.updated_at >= ?', days_ago).each do |project|
  project_data[project.id] = { name: project.name }
  project_data[project.id][:issues] = []

  project.issues.includes(:evidence, :tags).each do |issue|
    affected_list = issue.affected.map(&:label).uniq

    issue_data[issue.title]           ||= { assets: [], projects: [] }
    issue_data[issue.title][:assets]   << affected_list
    issue_data[issue.title][:projects] << project.id

    project_data[project.id][:issues] << {
      title: issue.title,
      affected: affected_list,
      tag: issue.tags.any? ? issue.tags.first.display_name : 'n/a'
    }
  end
end


# 2. Output summary
puts; puts; puts

# 2.1. Issues by project
project_data.each do |_, data|
  puts underline(data[:name])
  data[:issues].each do |issue|
    print "* [#{issue[:tag]}] #{issue[:title]}"
    puts issue[:affected].any? ? " affecting #{issue[:affected].to_sentence}" : ''
  end

  puts; puts
end

# 2.2. Issues in multiple projects
puts underline 'Issues found in multiple projects'
issue_data.select{ |title, data| data[:projects].length > 1 }.keys.uniq.sort.each do |title|
  puts "* #{title}"
end
puts; puts


# 2.3. Issues in a single project
puts underline 'Issues only found in one project'
issue_data.select{ |title, data| data[:projects].length == 1 }.keys.uniq.sort.each do |title|
  puts "* #{title}"
end
