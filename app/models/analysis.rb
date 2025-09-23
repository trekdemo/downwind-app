class Analysis < ApplicationRecord
  belongs_to :activity, touch: true

  broadcasts_refreshes_to :activity

  def route_bounds_calculated?
    return false unless route_bounds.present? && route_bounds.is_a?(Hash)

    required_keys = %w[north south east west]
    required_keys.all? { |key| route_bounds.key?(key) || route_bounds.key?(key.to_sym) }
  end
end
