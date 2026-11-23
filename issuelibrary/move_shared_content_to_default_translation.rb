# move_shared_content_to_default_translation.rb - Moves each IssueLibrary
#   Entry's shared content into its default Locale's Translation, and leaves the
#   shared content empty. Requires Dradis Pro v5.5 or later.
#
# - The default Translation keeps its QA state. An Entry with no default
#   Translation gets a new one, in Draft.
# - A default Translation that already has content keeps it: the shared fields
#   are added to it, and its own fields win.
# - Entries that also have Translations in other Locales are skipped, because
#   those Translations read the shared content they'd lose.
# - Every change is recorded in the Entry's and Translations' history, so it
#   can be reverted from the IssueLibrary.
#
# Back up your instance before running it.
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

default_locale = Dradis::Pro::Plugins::Issuelib::Locale.default

moved_count = 0
skipped_count = 0
failed_count = 0

puts "Moving IssueLibrary entries' shared content into the #{default_locale.name} (#{default_locale.code}) Translation"
if Dradis::Pro::Plugins::Issuelib::Locale.count > 1
  puts '(this instance has more than one Locale: Projects in other Locales read the shared content'
  puts "of Entries with no Translation in their Locale, and will find it empty once it's moved)"
end
puts

# Only Entries with shared content: there's nothing to move from the others,
# like Entries sent from a Project, whose content is already in a Translation.
entries = Dradis::Pro::Plugins::Issuelib::Entry.where.not(shared_content: [nil, '']).includes(:translations)

entries.find_each do |entry|
  title = entry.title
  others = entry.translations.reject { |translation| translation.locale_id == default_locale.id }

  # Skip Entries with a Translation in any other Locale, even with no default
  # Translation: those Translations are likely currently using the shared content they'd lose.
  if others.any?
    skipped_count += 1
    puts "  Skipped [##{entry.id}] #{title} (has #{others.size} other Translation#{'s' if others.size != 1})"
    next
  end

  default_translation = entry.translations.find { |translation| translation.locale_id == default_locale.id }
  created = default_translation.nil?
  default_translation ||= entry.translations.build(locale: default_locale, state: :draft)

  # The shared content as-is when the Translation has none of its own,
  # otherwise both merged with the Translation's fields winning, so it shows
  # the same fields as before. Worked out while the shared content is there.
  content =
    if default_translation.content.blank?
      entry.shared_content
    else
      FieldParser.fields_hash_to_source(default_translation.fields.except('id'))
    end

  begin
    ActiveRecord::Base.transaction do
      default_translation.update!(content: content)
      entry.update!(shared_content: '')
    end
  rescue ActiveRecord::ActiveRecordError => e
    failed_count += 1
    puts "  Failed [##{entry.id}] #{title}: #{e.message}"
    next
  end

  moved_count += 1
  puts "  Moved [##{entry.id}] #{title}#{' (new Draft Translation)' if created}"
end

puts
puts "Done. Moved #{moved_count}, skipped #{skipped_count}, failed #{failed_count}."
if skipped_count > 0
  puts 'Skipped entries have Translations in other Locales, which still read their shared content.'
end
