require 'rails_helper'

RSpec.describe "PWA files", type: :request do
  it "serves the web app manifest without a session" do
    get pwa_manifest_path(format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/json")
    manifest = response.parsed_body
    expect(manifest).to include("name" => "Foil Logbook", "display" => "standalone", "start_url" => "/")
    expect(manifest["icons"].map { it["sizes"] }).to include("192x192", "512x512")
    manifest["icons"].each { expect(Rails.public_path.join(it["src"].delete_prefix("/"))).to exist }
  end

  it "serves the service worker as JavaScript from the root scope" do
    get "/service-worker.js"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/javascript")
  end
end
