require "open-uri"

namespace :leaflet do
  desc "Vendor Leaflet JS, CSS and images: rails leaflet:update[1.9.4]"
  task :update, [ :version ] do |_, args|
    version = args.fetch(:version)
    base    = "https://unpkg.com/leaflet@#{version}/dist"
    dir     = Rails.root.join("vendor/assets/stylesheets")
    files   = %w[
      leaflet.css
      images/layers.png
      images/layers-2x.png
      images/marker-icon.png
      images/marker-icon-2x.png
      images/marker-shadow.png
    ]

    FileUtils.mkdir_p(dir.join("images"))
    files.each do |path|
      URI.open("#{base}/#{path}") { |io| File.binwrite(dir.join(path), io.read) }
    end

    sh "bin/importmap pin leaflet@#{version}"
  end
end
