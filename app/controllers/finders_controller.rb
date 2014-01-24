class FindersController < ApplicationController
  def show
    @finder = CMAFinder.new
  end
end
