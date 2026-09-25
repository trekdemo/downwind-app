namespace :import do
  desc "Import GPX files"
  task load: :environment do
    exit unless Rails.env.development?

    # Run analysis jobs inline: the default async adapter writes from
    # background threads, which locks the SQLite database.
    ActiveJob::Base.queue_adapter = :inline

    user = User.first
    user.activities.destroy_all

    FileList["activities/*-DW*.gpx"].each do |f|
      puts "Importing #{f}..."
      user.activities.create(gpx_file: File.new(f), lift_speed_kmh: 7, kind: :sup_dw)
    end
  end
end
