require "rails_helper"

RSpec.describe OnFoilSection do
  subject(:section) do
    described_class.new(
      started_at: Time.utc(2026, 5, 1, 10, 0, 0.5), ended_at: Time.utc(2026, 5, 1, 10, 0, 42),
      distance: 210.4, speed_avg: 5.01, speed_max: 6.2, hr_avg: 151.3, hr_max: 164, position: [ 47.1, 19.5 ]
    )
  end

  describe "#id" do
    it "is the start time in seconds since the epoch" do
      expect(section.id).to eq(Time.utc(2026, 5, 1, 10).to_i)
    end
  end

  describe "#failed_start?" do
    it "is true for sections of 5 seconds or less" do
      expect(section).not_to be_failed_start
      expect(section.with(ended_at: section.started_at + 5)).to be_failed_start
    end
  end

  describe "#to_time_window" do
    it "hands the map the id and the times to cut the section out of the route" do
      expect(section.to_time_window).to eq(
        id: Time.utc(2026, 5, 1, 10).to_i,
        started_at: "2026-05-01T10:00:00.500Z",
        ended_at: "2026-05-01T10:00:42.000Z"
      )
    end
  end
end
