# Dradis Professional scripting examples

This repo contains scripts you can run in the context of your Dradis Pro appliance. They show how to query the internal database to perform complex operations, gather statistics and more.


# How to use the scripts

1. Clone the repo into your laptop

```
git clone https://github.com/securityroots/dradispro-scripting.git
```

2. Choose one of the scripts or create a new one by modifying it for your needs.
3. SCP it across to your Dradis Pro appliance:

```
$ scp find_xss.rb dradispro@[dradis-ip]:/opt/dradispro/dradispro/current/
```

4. Run the script in the context of the application

```
$ ssh dradispro@[dradis-ip]
$ cd /opt/dradispro/dradispro/current/
$ RAILS_ENV=production bundle exec rails runner find_xss.rb
```

# List of scripts

* `bi_fields.rb` - Return the Custom Project Properties from the BI Dashboard for a specific project
* `/bash_files/bulk_upload.sh` - Upload multiple tool output files to a project at once, one plugin at a time
* `create_issue_node_evidence.rb` - Create an Issue, create a Node, and then create an instance of Evidence associated with both
* `create_project_apply_projecttemplate.rb` - Create a new Project and apply a Project Template, then return the Project ID.
* `create_project.rb` - Create a project with a name passed as argument and return the assigned ID
* `daily_summary.rb` - Finds and outputs all of the Issues added to Dradis in the past 24 hours
* `delete_nodes_without_evidence.rb` - Deletes Host Nodes that don't have any Evidence associated with them in a specific project
* `document_properties.rb` - Return your Document Properties from the Report Content
* `empty_trash.rb` - Deletes all projects from the instance-level trash
* `/erb_files/issue_id.html.erb` - Adds the unique issue identifier from your Dradis instance to each issue in a project in a new ID field
* `export_issuelib.rb` - Exports all your IssueLibrary entries to a single file
* `export_mappings_for_kit.rb` - Export the Mappings in a format that can be included in a kit
* `export_rt.rb` - Exports all your Remediation Tracker tickets to a single file
* `export_rules_for_kit.rb` - Export the rules in a format that can be included in a Kit or executed to build the ruleset
* `find_xss.rb` - Find recent projects with XSS Issues in them
* `load_project_from_api.rb` - Query a remote JSON API response to get project data and create matching Projects in the Dradis appliance
* `project_association_check.rb` - Checks to make sure all projects are associated with a report template
* `project_methodologies.rb` - Accesses each methodology for a project, then each list, and each card in that list. 
* `project_stats.rb` - Find which issues have been found across multiple projects and other project stats
* `recover_trash.rb` - Restores all the items from the Trash feature in a single project
* `send_to_rt.rb` - Sends all Issues in a given project to the Remediation Tracker as Tickets
* `top10.rb` - Creates tables of top 10 ports/protocols, services, and OSs in a content block
* `update_attachment_paths_to_v3.rb` - Updates attachment paths so they match the >= 3.0 format (after one project per tab was introduced)
* `update_attachments_after_node_merge.rb` - Find instances of attachments after merging nodes
* `update_content_blocks.rb` - Return and edit Content Blocks associated with a specific project
* `update_issuelib_entries.rb` - Find/replace and add fields to your IssueLibrary entries
* `usage_audit.rb` - Check to see a summary of usage per user over the last month
* `year_in_review.rb` - Yearly stats for your Dradis instance

# What does each script do?

Great question:

* Check the script source, there should be a comment near the top with a brief intro.
* Check the [Command Line Interface](http://securityroots.com/dradispro/support/guides/command_line/) guide in the support site.
