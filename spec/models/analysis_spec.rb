require 'rails_helper'

RSpec.describe Analysis, type: :model do
  describe '#route_center' do
    subject(:analysis) { described_class.new(route_bounds: { north: 0, south: 10, west: -5, east: 5 }) }

    it 'calculates center coordinates from route bounds' do
      center = analysis.route_center

      expect(center).to be_a(Hash)
      expect(center['lat']).to be_a(Float)
      expect(center['lng']).to be_a(Float)

      expect(center['lat']).to eq(5)
      expect(center['lng']).to eq(0)
    end
  end

  describe '#on_foil_sections' do
    it 'reads the stored sections back as OnFoilSections' do
      analysis = create(:analysis, :with_on_foil_sections).reload
      section = analysis.on_foil_sections.first

      expect(analysis.on_foil_sections.size).to eq(2)
      expect(section).to be_a(OnFoilSection)
      expect(section.started_at).to eq(Time.utc(2026, 5, 1, 10, 0, 0))
      expect(section.duration).to eq(42)
      expect(section.position).to eq([ 47.12345, 19.54321 ])
    end

    it 'leaves failed starts out of the shown sections' do
      analysis = create(:analysis, :with_on_foil_sections)
      failed = analysis.on_foil_sections.first.with(ended_at: analysis.on_foil_sections.first.started_at + 3)
      analysis.on_foil_sections = [ failed, *analysis.on_foil_sections.drop(1) ]

      expect(analysis.on_foil_sections.size).to eq(2)
      expect(analysis.successful_on_foil_sections).to eq(analysis.on_foil_sections.drop(1))
    end

    it 'is empty for analyses made before sections were stored' do
      expect(create(:analysis).on_foil_sections).to eq([])
    end
  end
end
