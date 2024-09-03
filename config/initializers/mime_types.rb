# https://en.wikipedia.org/wiki/GPS_Exchange_Format
# https://github.com/rails/marcel?tab=readme-ov-file#extending
Marcel::MimeType.extend "application/gpx+xml", extensions: %w[ gpx ], parents: "application/xml"
