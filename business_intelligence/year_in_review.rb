# year_in_review.rb - Yearly stats for your Dradis instance
#
# Copyright (C) 2019 Security Roots Ltd.
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

current_year = Date.today.year
year_start = "" 
year_start << Date.today.year.to_s
year_start << "-01-01"
year_start = Date.parse(year_start)

# Count of projects per year
project_count = Project.where("projects.created_at >= ? AND projects.created_at <= ?", year_start, DateTime.now).count
puts;puts
puts "#{project_count} Projects in #{current_year}\n\n"

@intC = 0
@intH = 0
@intM = 0
@intL = 0
@intI = 0
issue_data = {}
issue_crit = {}
issue_high = {}
issue_med = {}
sorted_data = {}

Project.where("projects.created_at >= ? AND projects.created_at <= ?", year_start, DateTime.now).each do |project|
  project.issues.includes(:evidence, :tags).each do |issue|
    if issue.tag_list == "!9467bd_critical"
      @intC += 1
      issue_crit[issue.title] ||= { projects: [] }
      issue_crit[issue.title][:projects] << project.id
    elsif issue.tag_list == "!d62728_high"
      @intH += 1
      issue_high[issue.title] ||= { projects: [] }
      issue_high[issue.title][:projects] << project.id
    elsif issue.tag_list == "!ff7f0e_medium"
      @intM += 1
      issue_med[issue.title] ||= { projects: [] }
      issue_med[issue.title][:projects] << project.id
    elsif issue.tag_list == "!6baed6_low"
      @intL += 1
    elsif issue.tag_list == "!2ca02c_info"
      @intI += 1
    end

    issue_data[issue.title] ||= { projects: [] }
    issue_data[issue.title][:projects] << project.id
  end
end
# Total Critical/High/Medium/Low Issues (by Tag) 
puts "Total Critical Issues: #{@intC}\n"
puts "Total High Issues: #{@intH}\n"
puts "Total Medium Issues: #{@intM}\n"
puts "Total Low Issues: #{@intL}\n"
puts "Total Info Issues: #{@intI}\n\n"

# Top 10 most found Issues (by title)
puts "Top 10 most found Issues (by title)"
sorted_data = issue_data.sort_by { |issue, data| data[:projects].count }.reverse.first(10)

sorted_data.reject{ |title, data| data[:projects].length == 1 }.each do |title, data|
  puts "* #{title} (#{data[:projects].count})"
end

# Top 10 most found Critical Issues (by title)
puts "\n\nTop 10 most found Critical Issues (by title)"
sorted_data = issue_crit.sort_by { |issue, data| data[:projects].count }.reverse.first(10)

sorted_data.reject{ |title, data| data[:projects].length == 1 }.each do |title, data|
  puts "* #{title} (#{data[:projects].count})"
end

# Top 10 most found High Issues (by title)
puts "\n\nTop 10 most found High Issues (by title)"
sorted_data = issue_high.sort_by { |issue, data| data[:projects].count }.reverse.first(10)

sorted_data.reject{ |title, data| data[:projects].length == 1 }.each do |title, data|
  puts "* #{title} (#{data[:projects].count})"
end

# Top 10 most found Medium Issues (by title)
puts "\n\nTop 10 most found Medium Issues (by title)"
sorted_data = issue_med.sort_by { |issue, data| data[:projects].count }.reverse.first(10)

sorted_data.reject{ |title, data| data[:projects].length == 1 }.each do |title, data|
  puts "* #{title} (#{data[:projects].count})"
end
