require "spec_helper"

RSpec.describe "Redirecting", type: :routing do
  context "related_to_brexit searches" do
    it "redirects to the Brexit handler" do
      expect(
        get: "/any-old-finder?related_to_brexit=d6c2de5d-ef90-45d1-82d4-5f2438369eea",
      ).to route_to(
        controller: "redirection",
        action: "redirect_brexit",
        slug: "any-old-finder",
        related_to_brexit: "d6c2de5d-ef90-45d1-82d4-5f2438369eea",
      )
    end

    it "doesn't redirect empty params" do
      expect(
        get: "/any-old-finder?related_to_brexit=",
      ).to route_to(
        controller: "finders",
        action: "show",
        slug: "any-old-finder",
        related_to_brexit: "",
      )
    end

    it "includes other params too" do
      expect(
        get: "/any-old-finder?keywords=booty&related_to_brexit=d6c2de5d-ef90-45d1-82d4-5f2438369eea&organisations[]=ministry-of-pirates",
      ).to route_to(
        controller: "redirection",
        action: "redirect_brexit",
        slug: "any-old-finder",
        keywords: "booty",
        organisations: %w[ministry-of-pirates],
        related_to_brexit: "d6c2de5d-ef90-45d1-82d4-5f2438369eea",
      )
    end
  end

  context "coronavirus topical event searches" do
    it "sends coronavirus topical event to a redirect (array params)" do
      expect(
        get: "/any-old-finder?topical_events[]=coronavirus-covid-19-uk-government-response",
      ).to route_to(
        controller: "redirection",
        action: "redirect_covid",
        slug: "any-old-finder",
        topical_events: %w[coronavirus-covid-19-uk-government-response],
      )
    end

    it "sends coronavirus topical event to a redirect (string params)" do
      expect(
        get: "/any-old-finder?topical_events=coronavirus-covid-19-uk-government-response",
      ).to route_to(
        controller: "redirection",
        action: "redirect_covid",
        slug: "any-old-finder",
        topical_events: "coronavirus-covid-19-uk-government-response",
      )
    end

    it "ignores other topical events" do
      expect(
        get: "/any-old-finder?topical_events[]=talk-like-a-pirate-day",
      ).to route_to(
        controller: "finders",
        action: "show",
        slug: "any-old-finder",
        topical_events: ["talk-like-a-pirate-day"],
      )
    end

    it "includes other params too" do
      expect(
        get: "/any-old-finder?keywords=bernard&topical_events[]=coronavirus-covid-19-uk-government-response&organisations[]=ministry-of-pirates",
      ).to route_to(
        controller: "redirection",
        action: "redirect_covid",
        slug: "any-old-finder",
        keywords: "bernard",
        organisations: %w[ministry-of-pirates],
        topical_events: %w[coronavirus-covid-19-uk-government-response],
      )
    end

    it "ignores atom feeds" do
      expect(
        get: "/any-old-finder.atom?keywords=bernard&topical_events[]=coronavirus-covid-19-uk-government-response&organisations[]=ministry-of-pirates",
      ).to route_to(
        format: "atom",
        controller: "finders",
        action: "show",
        slug: "any-old-finder",
        keywords: "bernard",
        organisations: %w[ministry-of-pirates],
        topical_events: %w[coronavirus-covid-19-uk-government-response],
      )
    end
  end
end
