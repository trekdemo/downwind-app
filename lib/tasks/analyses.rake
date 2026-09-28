namespace :analyses do
  desc "Re-analyze activities whose analysis has no route preview yet"
  task backfill_route_previews: :environment do
    activities = Activity.joins(:analysis).where(analyses: { route_preview: nil })

    puts "Enqueuing #{activities.count} activities for re-analysis..."
    activities.find_each(&:analyze_gpx_file_later)
  end
end
