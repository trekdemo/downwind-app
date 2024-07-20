# frozen_string_literal: true

require 'net/http'

class StaticMapsController < ApplicationController
  include ActivityMapsHelper

  before_action :set_activity, only: %i[show]

  def show
    path = @activity.reduced_path(50)
    url = path_map_url(path, size: params[:size], stroke_color: ColorScale.plasma[rand])
    Rails.logger.info "Requesting URL = #{url}"

    image = Net::HTTP.get_response(URI(url))
    send_data image.body, type: image.content_type, disposition: 'inline'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = current_user.activities.find(params[:activity_id])
  end
end
