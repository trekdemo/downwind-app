FactoryBot.define do
  factory :analysis do
    association :activity
    started_at { 1.hour.ago }
    ended_at { Time.current }
    duration { 3600.0 }
    starts { 5 }
    time_on_foil { 1800.0 }
    distance_total { 10000 }
    distance_on_foil { 8000 }
    speed_avg { 15.0 }
    speed_max { 25.0 }
    speed_avg_on_foil { 18.0 }
    hr_avg { 150.0 }
    hr_max { 180.0 }
    fastest_full_km { 120 }
    fastest_full_10km { 1500 }

    trait :with_on_foil_sections do
      on_foil_sections do
        [
          { started_at: Time.utc(2026, 5, 1, 10, 0, 0), ended_at: Time.utc(2026, 5, 1, 10, 0, 42), distance: 210.4, speed_avg: 5.01,
            speed_max: 6.2, hr_avg: 151.3, hr_max: 164, position: [ 47.12345, 19.54321 ] },
          { started_at: Time.utc(2026, 5, 1, 10, 3, 5), ended_at: Time.utc(2026, 5, 1, 10, 4, 0), distance: 305.0, speed_avg: 5.55,
            speed_max: 7.1, hr_avg: 158.0, hr_max: 171, position: [ 47.12401, 19.54412 ] }
        ]
      end
    end

    trait :with_route_preview do
      route_preview { [ [ 47.0, 19.0 ], [ 47.01, 19.0 ], [ 47.01, 19.02 ] ] }
    end
  end
end
