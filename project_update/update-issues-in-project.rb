if ARGV.size != 1
  puts "Usage:\n\tRAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} <project_id>"
  exit 1
end

pid = ARGV[0]
project = Project.find(pid)

project.issues.each do |issue|
  issue.set_field('Status', 'Open')
  issue.save
end
