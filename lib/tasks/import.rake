namespace :import do
  desc "Import GPX files"
  task load: :environment do
    exit unless Rails.env.development?

    user = User.first
    user.activities.destroy_all

    FileList["activities/*-DW*.gpx"].each do |f|
      puts "Importing #{f}..."
      user.activities.create(gpx_file: File.new(f), lift_speed_kmh: 7, kind: :sup_dw)
    end
  end
end
