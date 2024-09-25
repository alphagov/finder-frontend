require "spec_helper"

describe TitleContextHelper, type: :helper do
  include RegistrySpecHelper

  let(:filter_params) { {} }

  before do
    stub_topical_events_registry_request
  end

  describe "#title_context" do
    subject { title_context(filter_params) }

    context "there are no topical events" do
      it "gives no context" do
        expect(subject).to be_nil
      end
    end

    context "there is one topical event (as a string)" do
      let(:filter_params) { { "topical_events" => "2014-overseas-territories-joint-ministerial-council" } }

      it "gives context" do
        expect(subject).to eq("2014 Overseas Territories Joint Ministerial Council")
      end
    end

    context "there is one topical event (as an array)" do
      let(:filter_params) { { "topical_events" => %w[2014-overseas-territories-joint-ministerial-council] } }

      it "gives context" do
        expect(subject).to eq("2014 Overseas Territories Joint Ministerial Council")
      end
    end

    context "there is more than one topical event" do
      let(:filter_params) { { "topical_events" => %w[2014-overseas-territories-joint-ministerial-council anti-corruption-summit-london-2016] } }

      it "gives no context" do
        expect(subject).to be_nil
      end
    end
  end
end
