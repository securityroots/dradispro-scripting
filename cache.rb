# cache.rb - caches the list of issues for a project; useful for projects with
# large numbers of issues
#
# Copyright (C) 2023 Security Roots Ltd.
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
  puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} \"<project id>"
  exit 1
end


the_controller = ApplicationController.new
the_controller.class.send(:include, Rails.application.routes.url_helpers)

project = Project.find(ARGV[0])
issues = project.issues
tags = project.tags



the_controller.instance_variable_set "@all_columns", []
the_controller.instance_variable_set "@default_columns", []
the_controller.instance_variable_set "@issues", issues
the_controller.instance_variable_set "@tags", tags
the_controller.request = ActionDispatch::TestRequest.create

view_renderer = ActionView::Renderer.new the_controller.lookup_context
view_renderer.render the_controller.view_context, { partial: 'issues/table', layout: false, locals: { current_project: project, issues: issues, local_storage_key: "project.pro.#{project.id}.issues_datatable", tags: tags } }
