require "spec_helper"

RSpec.describe "maintenance", type: :request do
  before do
    Rails.application.config.maintenance_message = "The system will be unavailable for essential maintenance and will be back shortly"
    Rails.application.config.maintenance_mode = true
    Rails.application.reload_routes!
  end

  after do
    Rails.application.config.maintenance_mode = false
    Rails.application.reload_routes!
  end

  describe "GET show" do
    context "when the system is unavailable" do
      it "returns maintenance page" do
        get "/search/news-and-communications/email-signup"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Service unavailable")
        expect(response.body).to include("The system will be unavailable for essential maintenance and will be back shortly")
      end
    end
  end
end
