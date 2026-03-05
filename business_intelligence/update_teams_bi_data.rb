# update_teams_bi_data.rb - Update teams' BI data
#
# Copyright (C) 2026 Security Roots Ltd.
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

require "csv"

if ARGV.size != 1
  puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <csv_path>"
  exit 1
end

csv_path = ARGV[0]
unless File.exist?(csv_path)
  puts "CSV not found: #{csv_path}"
  exit 1
end

bi_fields_by_name = Dradis::Pro::BI::CustomField.where(model: "team").pluck(:name, :id).to_h
bi_fields_by_id = Dradis::Pro::BI::CustomField.where(model: "team").pluck(:id, :name).to_h

def parse_header_to_bi_id(header, bi_fields_by_name, bi_fields_by_id)
  return nil if header.nil?
  h = header.to_s.strip
  return nil if h.empty?
  return nil if h == "team_id" || h == "team_name"

  if (m = h.match(/\(#(\d+)\)\s*\z/))
    id = m[1].to_i
    return id if bi_fields_by_id.key?(id)
  end

  bi_fields_by_name[h]
end

header_to_bi_id = {}
csv_headers = nil

updated_teams = 0
updated_values = 0
updated_names = 0
skipped_rows = 0
unknown_headers = []

CSV.foreach(csv_path, headers: true) do |row|
  if csv_headers.nil?
    csv_headers = row.headers
    csv_headers.each do |h|
      next if h.nil?
      bi_id = parse_header_to_bi_id(h, bi_fields_by_name, bi_fields_by_id)
      header_to_bi_id[h] = bi_id
      unknown_headers << h if bi_id.nil? && !%w[team_id team_name].include?(h)
    end
  end

  tid_str = row["team_id"].to_s.strip
  if tid_str.empty?
    skipped_rows += 1
    next
  end

  team = Team.find_by(id: tid_str.to_i)
  unless team
    skipped_rows += 1
    next
  end

  changed_any = false

  csv_team_name = row["team_name"]
  if !csv_team_name.nil?
    csv_team_name = csv_team_name.to_s
    if !csv_team_name.strip.empty? && team.name.to_s != csv_team_name
      team.name = csv_team_name
      changed_any = true
      updated_names += 1
    end
  end

  csv_headers.each do |h|
    bi_id = header_to_bi_id[h]
    next unless bi_id

    new_val = row[h]
    next if new_val.nil?
    new_val = new_val.to_s
    next if new_val.strip.empty?

    cfv = team.custom_field_values.find { |v| v.custom_field_id == bi_id }
    if cfv
      next if cfv.value.to_s == new_val
      cfv.value = new_val
    else
      cfv = team.custom_field_values.build(custom_field_id: bi_id, value: new_val)
    end

    cfv.save!
    changed_any = true
    updated_values += 1
  end

  if changed_any
    team.save! if team.changed?
    updated_teams += 1
  end
end

puts "CSV: #{csv_path}"
puts "Teams updated: #{updated_teams}"
puts "Team names updated: #{updated_names}"
puts "BI values updated: #{updated_values}"
puts "Rows skipped: #{skipped_rows}"
if unknown_headers.any?
  puts "Unknown BI headers (ignored): #{unknown_headers.uniq.join(", ")}"
end
