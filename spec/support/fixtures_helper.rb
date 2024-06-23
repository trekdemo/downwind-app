require 'pathname'

module FixturesHelper
  FIXTURES_PATH = Pathname(__dir__).join('../fixtures')

  def fixture(fname)
    FIXTURES_PATH.join(fname)
  end
end
