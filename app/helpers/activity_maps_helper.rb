# frozen_string_literal: true

module ActivityMapsHelper
  # FIXME: This method should not be used from the view because it contains the
  # Mapbox credential
  # https://docs.mapbox.com/api/maps/static-images/#path
  def path_map_url(_path, size:, stroke_width: 2, stroke_color: '000', stroke_opacity: 1)
    format(
      'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/'\
      'path-%<stroke_width>s+%<stroke_color>s-%<stroke_opacity>s(%<polyline>s)'\
      '/auto/%<size>s@2x'\
      '?access_token=%<token>s',
      {
        stroke_width:, stroke_color: stroke_color.sub('#', ''), stroke_opacity:, size:,
        polyline: '%7DrpeFxbnjVsFwdAvr@cHgFor@jEmAlFmEMwM_FuItCkOi@wc@bg@wBSgM',
        token: ENV.fetch('MAPBOX_ACCESS_TOKEN')
      }
    )
  end
end
