# bulk_import_projects.rb - Import multiple Dradis project Package zip files at once.
#
# Uses Dradis::Plugins::Projects::Upload::Package::Importer directly — no thor
# required — so it works identically on VM and Docker deployments.
#
# Accepts either:
#   a) A directory of .zip package files  (--input-dir)
#   b) A single bulk_export bundle zip    (--bundle)
#
# Each package is imported into a fresh project. The importer overwrites the
# placeholder project name with the one stored inside the package.
#
# Usage (VM — run from /opt/dradispro/dradispro/current/):
#
#   RAILS_ENV=production bundle exec rails runner bulk_import_projects.rb \
#     --input-dir /tmp/dradis_exports [--owner-id 1]
#
# Usage (Docker):
#
#   # Copy packages into the container first:
#   docker cp /path/to/exports/. app:/tmp/dradis_exports/
#
#   # Then run the script inside the container:
#   docker exec -it app bundle exec rails runner /tmp/bulk_import_projects.rb \
#     --input-dir /tmp/dradis_exports [--owner-id 1]
#
# Import from a bulk_export bundle (works on both VM and Docker):
#
#   RAILS_ENV=production bundle exec rails runner bulk_import_projects.rb \
#     --bundle /tmp/dradis_exports/bulk_export_20250520_143000.zip [--owner-id 1]

require 'fileutils'
require 'tmpdir'
require 'zip'   # rubyzip, already present in Dradis

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
input_dir = nil
bundle    = nil
owner_id  = nil

i = 0
while i < ARGV.size
  case ARGV[i]
  when '--input-dir'
    input_dir = ARGV[i + 1]
    i += 2
  when '--bundle'
    bundle = ARGV[i + 1]
    i += 2
  when '--owner-id'
    owner_id = ARGV[i + 1].to_i
    i += 2
  else
    i += 1
  end
end

unless input_dir || bundle
  puts "Usage:"
  puts "  RAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} \\"
  puts "    --input-dir <dir>  [--owner-id <user_id>]"
  puts "  OR"
  puts "  RAILS_ENV=#{Rails.env} bundle exec rails runner #{$0} \\"
  puts "    --bundle <zip>     [--owner-id <user_id>]"
  exit 1
end

owner_id ||= User.first.id
owner = User.find_by_id(owner_id) || User.first
puts "Importing as user: #{owner.email} (id=#{owner.id})"

rails_root = Rails.root.to_s
rails_env  = Rails.env

# ---------------------------------------------------------------------------
# Resolve package files
# ---------------------------------------------------------------------------
work_dir = nil
packages = []

if bundle
  work_dir = Dir.mktmpdir('dradis_bulk_import_')
  puts "Unpacking bundle: #{bundle} -> #{work_dir}"
  Zip::File.open(bundle) do |zip|
    zip.each do |entry|
      dest = File.join(work_dir, entry.name)
      entry.extract(dest) { true }
    end
  end
  packages = Dir[File.join(work_dir, '*.zip')].sort
elsif input_dir
  packages = Dir[File.join(input_dir, '*.zip')].sort
end

if packages.empty?
  puts "No .zip package files found."
  FileUtils.rm_rf(work_dir) if work_dir
  exit 1
end

puts "Found #{packages.size} package(s) to import.\n\n"

# ---------------------------------------------------------------------------
# Import each package
# ---------------------------------------------------------------------------
imported = []
failed   = []

packages.each do |pkg_path|
  label = File.basename(pkg_path)

  begin
    # Create a blank project to import into
    project = Project.new(name: label.sub(/\.zip$/i, ''))
    raise "Could not create placeholder project: #{project.errors.full_messages.join(', ')}" unless project.save

    project.assign_owner(owner)

    # Use the Importer directly (same code path as the thor task and the UI).
    # The importer will overwrite the project name from the package contents.
    plugin   = Dradis::Plugins::Projects::Upload::Package
    importer = plugin::Importer.new(
      default_user_id: owner.id,
      logger:          Logger.new($stdout),
      plugin:          plugin,
      project_id:      project.id
    )
    importer.import(file: pkg_path)
    project.reload

    puts "  [OK]   #{label}  ->  project #{project.id}: #{project.name}"
    imported << project

  rescue => e
    puts "  [FAIL] #{label}  ->  #{e.message}"
    failed << label
  end
end

# ---------------------------------------------------------------------------
# Cleanup and summary
# ---------------------------------------------------------------------------
FileUtils.rm_rf(work_dir) if work_dir

puts "\nDone. #{imported.size} imported, #{failed.size} failed."
failed.each { |f| puts "  FAILED: #{f}" }

exit(failed.any? ? 2 : 0)
