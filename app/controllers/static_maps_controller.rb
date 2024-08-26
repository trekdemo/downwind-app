# frozen_string_literal: true

require "net/http"

class StaticMapsController < ApplicationController
  include ActivityMapsHelper

  def show
    @activity = current_user.activities.find(params[:activity_id])
    url = speed_map_url(@activity, size: params[:size])
    Rails.logger.debug "Requesting URL = #{url}"

    image = Net::HTTP.get_response(URI(url))
    send_data image.body, type: image.content_type, disposition: "inline"
  end
end
