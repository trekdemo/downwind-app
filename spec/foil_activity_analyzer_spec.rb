require_relative '../foil_activity_analyzer'

RSpec.describe FoilActivityAnalyzer do
  subject(:analyzer) { FoilActivityAnalyzer.new(fixture('wing-activity.gpx'), 15) }

  describe '#starts' do
    it 'counts the number of time the average speed is above the lift speed' do
      expect(analyzer.starts).to eq(17)
    end
  end

  describe '#speed_avg' do
    it 'counts the number of time the average speed is above the lift speed' do
      expect(analyzer.speed_avg).to eq(4.291928004881026)
    end
  end

  describe '#duration' do
    it 'calculates the duration' do
      expect(analyzer.duration).to eq(3599.0)
    end
  end
end
