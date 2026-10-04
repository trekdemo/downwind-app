class Analysis < ApplicationRecord
  belongs_to :activity, touch: true

  broadcasts_refreshes_to :activity

  # @!attribute route_bounds
  #   @return [Hash] The name of the task.

  # Empty for analyses made before sections were stored
  attribute :on_foil_sections, OnFoilSection::ListType.new

  # The sections worth showing; failed starts still count in `starts`
  def successful_on_foil_sections = on_foil_sections.reject(&:failed_start?)

  def route_center
    {
      "lat" => (route_bounds["north"] + route_bounds["south"]) / 2.0,
      "lng" => (route_bounds["east"] + route_bounds["west"]) / 2.0
    }
  end
end
