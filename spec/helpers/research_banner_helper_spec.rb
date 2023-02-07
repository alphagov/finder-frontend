require "spec_helper"

describe ResearchBannerHelper, type: :helper do
  include ResearchBannerHelper

  context "for the UKMCAB finder" do
    subject(:subject) { show_banner?("/uk-market-conformity-assessment-bodies") }

    it "should display the banner" do
      expect(subject).to be_truthy
    end
  end

  context "for other finders" do
    subject(:subject) { show_banner?("/lunch-finder") }

    it "should not display the banner" do
      expect(subject).to be_falsey
    end
  end
end
