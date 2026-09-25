FactoryBot.define do
  factory :activity do
    association :user
    title { "Test Activity" }
    lift_speed_kmh { 15.0 }
    started_at { 1.hour.ago }
    kind { :sup_dw }

    # Add a GPX file attachment using a simple GPX content
    after(:build) do |activity|
      activity.gpx_file.attach(
        io: StringIO.new(<<~GPX),
          <?xml version="1.0" encoding="UTF-8"?>
          <gpx version="1.1" creator="test">
            <trk>
              <trkseg>
                <trkpt lat="40.7128" lon="-74.0060">
                  <time>2023-01-01T10:00:00Z</time>
                </trkpt>
                <trkpt lat="40.7129" lon="-74.0061">
                  <time>2023-01-01T10:01:00Z</time>
                </trkpt>
              </trkseg>
            </trk>
          </gpx>
        GPX
        filename: 'test.gpx',
        content_type: 'application/gpx+xml'
      )
    end
  end
end
