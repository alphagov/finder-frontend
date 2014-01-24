require 'spec_helper'

describe FindersController do
  let(:slug) { "cma-cases" }

  describe :show do
    before { get :show, slug: slug }

    it "should assign a hard-coded CMAFinder to @finder" do
      assigns(:finder).should be_a(CMAFinder)
    end
  end
end
