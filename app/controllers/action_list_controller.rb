# This class currently supports only one question
# If there is a need for multiple questions, this class needs to be modified

class ActionListController < ApplicationController
  layout "finder_layout"

  def show
    render "action_list/show"
  end

private
  def title
    "Prepare for Brexit action list"
  end
  helper_method :title

  def breadcrumbs
    [
      { title: "Home", url: "/" },
      { title: "Prepare for Brexit", url: prepare_everyone_uk_leaving_eu_path }
    ]
  end
  helper_method :breadcrumbs
end
