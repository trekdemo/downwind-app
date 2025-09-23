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
  end
end