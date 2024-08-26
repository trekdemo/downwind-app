require "clearance/rspec"

# From https://github.com/thoughtbot/clearance/pull/986
module Clearance
  module Testing
    # Provides helpers to your request specs.
    # These are typically used in tests by requiring `clearance/rspec` or
    # `clearance/test_unit` as appropriate in your `rails_helper.rb` or
    # `test_helper.rb` files.
    module RequestHelpers
      # Signs in the provided user.
      #
      # @param [User class] user
      # @param [String] password
      # @param [String] path

      # @return user
      def sign_in_as(user, password:, path: session_path)
        post path, params: {
          session: { email: user.email, password: password }
        }

        user
      end

      # Signs out a user that may be signed in.
      #
      # @param [String] path
      #
      # @return [void]
      def sign_out(path: sign_out_path)
        delete path
      end
    end
  end
end

RSpec.configure do |config|
  config.include Clearance::Testing::RequestHelpers, type: :request
end
