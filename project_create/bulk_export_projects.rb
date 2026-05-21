# bulk_export_projects.rb - Export multiple Dradis projects as Package zip files.
#
# For VM deployments only. Run from /opt/dradispro/dradispro/current/ as dradispro.
#
# For Docker deployments, use bulk_export_projects_docker.sh instead.
#
# Usage:
#   # Export ALL projects:
#   RAILS_ENV=production bundle exec rails runner bulk_export_projects.rb \
#     --output /tmp/dradis_exports
#
#   # Export specific projects by ID:
#   RAILS_ENV=production bundle exec rails runner bulk_export_projects.rb \
#     --output /tmp/dradis_exports --ids 1,4,7,12
#
# Output:
#   /tmp/dradis_exports/project_1_my_project.zip
#   /tmp/dradis_exports/project_4_another_project.zip
#   ...
#   /tmp/dradis_exports/bulk_export_<timestamp>.zip   <- everything bundled

require 'fileutils'
require 'zip'   # rubyzip, already present in Dradis

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
output_dir  = nil
project_ids = nil

i = 0
while i < ARGV.size
  case ARGV[i]
  when '--output'
    output_dir = ARGV[i + 1]; i += 2
  when '--ids'
    project_ids = ARGV[i + 1].split(',').map(&:strip).map(&:to_i); i += 2
  else
    i += 1
  end
end

unless output_dir
  puts "Usage:"
  puts "  RAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} \\"
  puts "    --output <dir> [--ids 1,2,3]"
  puts ""
  puts "For Docker, use bulk_export_projects_docker.sh on the host instead."
  exit 1
end

FileUtils.mkdir_p(output_dir)

# ---------------------------------------------------------------------------
# Resolve projects
# ---------------------------------------------------------------------------
projects = project_ids ? Project.kept.where(id: project_ids) : Project.kept

if projects.empty?
  puts "No projects found."
  exit 1
end

puts "Exporting #{projects.count} project(s) to: #{output_dir}\n\n"

exported = []
failed   = []

projects.each do |project|
  safe_name = project.name.gsub(/[^A-Za-z0-9_\-]/, '_').squeeze('_').downcase
  dest_name = "project_#{project.id}_#{safe_name}.zip"
  dest_path = File.join(output_dir, dest_name)

  cmd    = "cd #{Rails.root} && PROJECT_ID=#{project.id} RAILS_ENV=#{Rails.env} " \
           "bundle exec thor dradis:plugins:projects:export:package 2>&1"
  output = `#{cmd}`

  # Strip ANSI codes, then find the path which appears on the line after the marker
  output_clean  = output.gsub(/\e\[[0-9;]*m/, '')
  exported_path = output_clean[/Project package created at:[\s\t]*(\S+\.zip)/i, 1]

  if $?.success? && exported_path && File.exist?(exported_path)
    FileUtils.mv(exported_path, dest_path)
    puts "  [OK]   project #{project.id}: #{project.name}  ->  #{dest_name}"
    exported << dest_path
  else
    puts "  [FAIL] project #{project.id}: #{project.name}"
    puts output.gsub(/^/, "         ") unless output.empty?
    failed << project
  end
end

# ---------------------------------------------------------------------------
# Bundle into one archive
# ---------------------------------------------------------------------------
if exported.any?
  timestamp   = Time.now.strftime('%Y%m%d_%H%M%S')
  bundle_path = File.join(output_dir, "bulk_export_#{timestamp}.zip")

  Zip::File.open(bundle_path, Zip::File::CREATE) do |zipfile|
    exported.each { |path| zipfile.add(File.basename(path), path) }
  end

  puts "\nBundle: #{bundle_path}"
end

puts "\nDone. #{exported.size} exported, #{failed.size} failed."
failed.each { |p| puts "  FAILED: project #{p.id} - #{p.name}" }

exit(failed.any? ? 2 : 0)
