# usage_audit.rb - Check to see a summary of usage per user 
# over the last month
#
# Copyright (C) 2018 Security Roots Ltd.
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

puts

month_ago = DateTime.now - 1.month

puts "### Summary of usage by user over the last month ###"
puts "Between #{month_ago} and #{DateTime.now}"
puts

all_users = User.all
all_users.each do |user|
	
	@issue_destroy = 0
	@issue_create = 0
	@issue_update = 0

	Activity.where("updated_at >= ? AND updated_at <= ?", month_ago, DateTime.now).each do |activity|
    if activity.user_id == user.id
    	if activity.trackable_type == "Issue"
    		if activity.action == "destroy"
    			@issue_destroy += 1
    		elsif activity.action == "create"
    			@issue_create += 1
    		elsif activity.action == "update"
    			@issue_update += 1
    		end
    	end
    end
	end

	puts "#{user.email}"
	puts "  - issues created: #{@issue_create.to_s}"
	puts "  - issues deleted #{@issue_destroy.to_s}"
	puts "  - issues updated #{@issue_update.to_s}"
	puts
end
