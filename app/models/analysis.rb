class Analysis < ApplicationRecord
  belongs_to :activity, touch: true

  broadcasts_refreshes_to :activity

  # @!attribute route_bounds
  #   @return [Hash] The name of the task.

  def route_center
    {
      "lat" => (route_bounds["north"] + route_bounds["south"]) / 2.0,
      "lng" => (route_bounds["east"] + route_bounds["west"]) / 2.0
    }
  end
end
