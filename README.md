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

* `create_project.rb` - Create a project with a name passed as argument and return the assigned ID.
* `find_xss.rb` - Find recent projects with XSS Issues in them.
* `load_project_from_api` - Query a remote JSON API response to get project data and create matching Projects in the Dradis appliance.
* `project_stats.rb` - Find which issues have been found across multiple projects and other project stats.


# What does each script do?

Great question:

* Check the script source, there should be a comment near the top with a brief intro.
* Check the [Command Line Interface](http://securityroots.com/dradispro/support/guides/command_line/) guide in the support site.
