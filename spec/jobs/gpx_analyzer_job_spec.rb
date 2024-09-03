require 'rails_helper'

RSpec.describe ActivityAnalyzerJob, type: :job do
  describe '#perform' do
    it 'calls the #analyze_gpx_file! method' do
      activity = instance_double('Activity')
      expect(activity).to receive(:analyze_gpx_file!)

      described_class.new.perform(activity)
    end
  end
end
