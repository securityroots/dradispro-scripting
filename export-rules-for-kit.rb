
# This script for Dradis will export the rules in a format that can be included in a Kit or
# executed to build the ruleset

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