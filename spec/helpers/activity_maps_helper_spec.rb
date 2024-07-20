require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the MappingHelper. For example:
#
RSpec.describe ActivityMapsHelper, type: :helper do
  describe '#path_map_url' do
    it 'returns url based on path' do
      path = []
      expect(path_map_url(path, size: '100x100', stroke_width: 5, stroke_color: 'f44', stroke_opacity: 0.5)).to eq(
        'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/path-5+f44-0.5(%7DrpeFxbnjVsFwdAvr@cHgFor@jEmAlFmEMwM_FuItCkOi@wc@bg@wBSgM)/auto/100x100@2x?access_token=token'
      )
    end
  end
end
