class PostCodeLookupController < ApplicationController
  layout "finder_layout"

  def show
    render('post_code_lookup/show')
  end

end