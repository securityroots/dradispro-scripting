# update_entries.rb - Updates all IssueLibrary entries to replace plugin_id with nessus_id (if found), 
#   adds a new Status field, and sets the state to "Ready for Review"
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

Dradis::Pro::Plugins::Issuelib::Entry.all.each do |libentry|
  libentry.content << "\r\n\r\n#[Status]#\r\nOpen | Closed\r\n"
  puts "Adding fields to IssueLibrary entry #{libentry.id}"
  
  if libentry.content.include? "#[plugin_id]#"
    libentry.content.sub!('#[plugin_id]#', '#[nessus_id]#')
    libentry.save
    puts "Replacing fields in IssueLibrary entry #{libentry.id}"
  end

  libentry.state = "ready_for_review"
  puts "Setting entry #{libentry.id}'s state to 'Ready for Review'"
  libentry.save
end
