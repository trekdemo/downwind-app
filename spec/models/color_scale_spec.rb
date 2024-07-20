require 'rails_helper'

RSpec.describe ColorScale, type: :model do
  describe '.plasma' do
    subject(:scale) { described_class.plasma }
    {
      0 => '#0d0887',
      0.5 => '#cc4778',
      1 => '#f0f921'
    }.each do |t, color|
      it("#{t} => #{color}") { expect(scale[t]).to eq(color) }
    end
  end
end
