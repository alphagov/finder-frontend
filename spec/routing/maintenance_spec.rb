require "spec_helper"

RSpec.describe "Maintenance Page", type: :routing do
  context "when the maintenance variable is set" do
    before do
      Rails.application.config.maintenance_mode = true
      Rails.application.reload_routes!
    end

    after do
      Rails.application.config.maintenance_mode = false
      Rails.application.reload_routes!
    end

    it "routes to the maintenance controller for get" do
      expect(get: "/search/news-and-communications/email-signup")
      .to route_to(controller: "maintenance", action: "show", "slug" => "search/news-and-communications")
    end

    it "routes to the maintenance controller for post" do
      expect(post: "/search/news-and-communications/email-signup")
      .to route_to(controller: "maintenance", action: "show", "slug" => "search/news-and-communications")
    end
  end

  context "when the maintenance variable is not set" do
    it "routes to the usual controller" do
      expect(get: "/email-signup")
      .to route_to(controller: "finders", action: "show", "slug" => "email-signup")
    end
  end
end
