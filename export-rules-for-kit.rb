
# export_rules_for_kit.rb - Export the rules in a format that can be included in a Kit or
#   executed to build the ruleset
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

Dradis::Pro::Rules::Rule.find do |the_rule|
  puts "\# #{the_rule.name}"
  puts "rule#{the_rule.id} = #{the_rule.type}.create!(name: \"#{the_rule.name}\")"

  Dradis::Pro::Rules::Conditions::FieldCondition.where(rule_id: the_rule.id).each do |fc|
    puts "#{fc.type}.create!(rule: rule#{the_rule.id}, properties: #{fc.properties})"
  end

  Dradis::Pro::Rules::Action.where(rule_id: the_rule.id).each do |fc|
    puts "#{fc.type}.create!(rule: rule#{the_rule.id}, properties: #{fc.properties})"
  end

  puts ""
end