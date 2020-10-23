require "spec_helper"

describe BrexitCheckerController, type: :controller do
  include GovukAbTesting::RspecHelpers

  context "results page AB test" do
    render_views
    subject { get :results }

    %w[A B Z].each do |variant|
      it "Variant #{variant} includes the AB testing headers and metatags" do
        with_variant TransitionUrgency5: variant do
          expect(subject).to render_template(:results)
        end
      end
    end
  end
end
