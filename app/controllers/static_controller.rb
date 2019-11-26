class StaticController < ApplicationController
  # hide search box
  include Slimmer::Headers
  before_action -> { set_slimmer_headers(remove_search: true) }
  layout 'static_layout'
  def home
  end
end
