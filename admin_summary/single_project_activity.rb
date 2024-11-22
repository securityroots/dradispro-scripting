# single_project_activity.v2.rb - Returns all activity for 1 project
# Activities covered: Issues, Evidence, Nodes, Notes, ContentBlocks,
# Methodology Boards, Methodology Lists, Methodology Cards, Comments, and Tags
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

if ARGV.size != 1
 puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <project_id>"
 exit 1
end

pid = ARGV[0]
project  = Project.find(pid)

Activity.where(project_id: pid).order(:created_at).reverse.each do |activity| # Most recent activity first
  if User.exists?(id: activity.user_id) # CMake sure that the user exists/was not deleted
    if project.authors.exists?(id: activity.user_id) # Make sure the user still has access to the project
      user_name = project.authors.find(activity.user_id).name
    else # The user no longer has access to the project
      user_name = "#{User.find(activity.user_id).name}, who no longer has access to the project, "
    end
  else # The user no longer exists on the instance
    user_name = "User who has since been deleted"
  end

  if activity.trackable_type == 'Issue' # Each activity type is treated differently for output messages
    if Issue.exists?(id: activity.trackable_id)
      issue = Issue.find(activity.trackable_id)
      if activity.action == 'state_change' # Only Issues and Content Block have QA states to track
        action = "updated the #{issue.title} issue's state to #{issue.state.humanize.downcase}, #{activity.created_at}"
      else
        action = "#{activity.action}d the #{issue.title} issue, #{activity.created_at}"
      end
    else
      if activity.action == 'destroy'
        action = "deleted an issue, #{activity.created_at}"
      else
        action = "#{activity.action}d an Issue which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'ContentBlock' 
    if ContentBlock.exists?(id: activity.trackable_id)
      content_block = ContentBlock.find(activity.trackable_id)
      if activity.action == 'state_change' # Only Issues and Content Block have QA states to track
        action = "updated the #{content_block.title} content block's state to #{content_block.state.humanize.downcase}, #{activity.created_at}"
      else
        action = "#{activity.action}d the #{content_block.title} content block, #{activity.created_at}"
      end
    else
      if activity.action == 'destroy'
        action = "deleted a content block, #{activity.created_at}"
      else
        action = "#{activity.action}d a content block which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'Evidence'
    if Evidence.exists?(id: activity.trackable_id)
      evidence = Evidence.find(activity.trackable_id)
      action = "#{activity.action}d created a piece of evidence for #{evidence.issue.title} at #{evidence.node.label}, #{activity.created_at}"
    else
      if activity.action == 'destroy'
        action = "deleted an instance of Evidence, #{activity.created_at}"
      else
        action = "#{activity.action}d an instance of Evidence which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'Comment'
    if Comment.exists?(id: activity.trackable_id)
      comment = Comment.find(activity.trackable_id)
      action = "#{activity.action}d the comment on #{comment.commentable.title}, #{activity.created_at}"
    else
      if activity.action == 'destroy'
        action = "deleted a comment, #{activity.created_at}"
      else
        action = "#{activity.action}d a comment which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'Tag'
    if Tag.exists?(id: activity.trackable_id)
      tag = Tag.find(activity.trackable_id)
      action = "#{activity.action}d the #{tag.display_name} tag, #{activity.created_at}"
    else
      if activity.action == 'destroy'
        action = "deleted a tag, #{activity.created_at}"
      else
        action = "#{activity.action}d a tag which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'List'
    if List.exists?(id: activity.trackable_id)
      list = List.find(activity.trackable_id)
      action = "#{activity.action}d the #{list.name} list in the #{list.board.name} methodology, #{activity.created_at}"
    else
      if activity.action == 'destroy'
        action = "deleted a list, #{activity.created_at}"
      else
        action = "#{activity.action}d a list which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'Card'
    if Card.exists?(id: activity.trackable_id)
      card = Card.find(activity.trackable_id)
      action = "#{activity.action}d the #{card.name} card in the #{card.list.board.name} methodology, #{activity.created_at}"
    else
      if activity.action == 'destroy'
        action = "deleted a card, #{activity.created_at}"
      else
        action = "#{activity.action}d a card which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'Board'
    if Board.exists?(id: activity.trackable_id)
      board = Board.find(activity.trackable_id)
      action = "#{activity.action}d the #{board.name} methodology, #{activity.created_at}"
    else
      if activity.action == 'destroy'
        action = "deleted a methodology, #{activity.created_at}"
      else
        action = "#{activity.action}d a methodology which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'Node'
    if Node.exists?(id: activity.trackable_id)
      node = Node.find(activity.trackable_id)
      action = "#{activity.action}d the #{node.label} node, #{activity.created_at}"
    else
      if activity.action == 'destroy'
        action = "deleted a node, #{activity.created_at}"
      else
        action = "#{activity.action}d a node which has since been destroyed, #{activity.created_at}"
      end
    end
  elsif activity.trackable_type == 'Note'
    if Note.exists?(id: activity.trackable_id)
      note = Note.find(activity.trackable_id)
      action = "#{activity.action}d the #{note.title} note at #{note.node.label}, #{activity.created_at}"
    else
      if activity.action == 'destroy'
        action = "deleted a note, #{activity.created_at}"
      else
        action = "#{activity.action}d a note which has since been destroyed, #{activity.created_at}"
      end
    end
  end
  puts "#{user_name} #{action}" # Output the name, then the action, for each Activity
end
