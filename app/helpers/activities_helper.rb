module ActivitiesHelper
  def number_to_distance(distance)
    number_to_human(distance, units: { unit: 'm', thousand: 'km' })
  end

  def number_to_speed(distance)
    number_to_human(distance, precision: 1, units: { unit: 'km/h' })
  end
end
