require 'gds_api/helpers'

class FindersController < ApplicationController
  include GdsApi::Helpers
  before_filter :apply_policy_finder_default_date

  def show
    @results = ResultSetPresenter.new(finder, facet_params)

    respond_to do |format|
      format.html
      format.json do
        render json: @results
      end
      format.atom do
        @feed = AtomPresenter.new(finder)
      end
    end
  end

private
  def finder
    @finder ||= FinderPresenter.new(
      content_store.content_item!("/#{finder_slug}"),
      facet_params,
      keywords,
    )
  end
  helper_method :finder

  def facet_params
    # TODO Use a whitelist based on the facets in the schema
    params.except(
      :controller,
      :action,
      :slug,
      :format,
    )
  end

  def keywords
    params[:keywords] unless params[:keywords].blank?
  end

  def apply_policy_finder_default_date
    # SHORT-TERM HACK AHOY
    # This this will be used for a few weeks post-election and should be
    # completely removed afterewards. It only applies to a policy finders, (eg
    # /government/policies/benefits-reform, but not the finder of policies, eg
    # /government/policies nor any other finders, eg, /cma-cases)

    # This will not show documents-related-to-policy published under the previous
    # government, though they can been seen by removing/changing the published
    # after date in the finder UI.

    # Needs updating if the government is not formed the day after polling
    # set in the format of 'DD/MM/YYYY'
    date_new_government_formed = nil

    is_policy_finder = finder_slug.starts_with?("government/policies/")
    has_date_param = params[:public_timestamp]

    if date_new_government_formed && is_policy_finder && !has_date_param
      params[:public_timestamp] = {from: date_new_government_formed}
    end
  end
end
