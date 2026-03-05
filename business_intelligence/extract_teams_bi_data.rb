# extract_teams_bi_data.rb - Extract teams' BI data
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

out_path =
  if ARGV.size == 1
    ARGV[0]
  else
    "teams_bi_dump_#{Time.now.strftime("%Y%m%d_%H%M%S")}.csv"
  end

bi_fields =
  Dradis::Pro::BI::CustomField
    .where(model: "team")
    .order(:id)
    .pluck(:id, :name)

name_counts = Hash.new(0)
headers =
  ["team_id", "team_name"] +
  bi_fields.map do |id, name|
    name_counts[name] += 1
    name_counts[name] == 1 ? name : "#{name} (##{id})"
  end

CSV.open(out_path, "wb") do |csv|
  csv << headers

  Team.find_each do |team|
    values_by_id = {}
    team.custom_field_values.each do |cfv|
      values_by_id[cfv.custom_field_id] = cfv.value
    end

    row =
      [team.id, team.name] +
      bi_fields.map { |id, _| values_by_id[id].to_s }

    csv << row
  end
end

puts "Wrote #{out_path}"
