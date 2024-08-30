require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the MappingHelper. For example:
#
RSpec.describe ApplicationHelper, type: :helper do
  describe '#options_for_enum' do
    it 'returns a nested array' do
      stub_const 'TestDoor', Class.new(ApplicationRecord) do
      end
      def TestDoor.statuses = { 'open' => 0, 'closed' => 1 }

      expect(options_for_enum(TestDoor, :status))
        .to match_array([ [ 'Open', 'open' ], [ 'Closed', 'closed' ] ])
    end
  end
end
