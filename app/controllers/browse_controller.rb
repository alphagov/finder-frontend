class BrowseController < ApplicationController
  layout "browse_layout"

  before_action :hide_search_box

  before_action do
    expires_in(5.minutes, public: true)
  end

  def index
    respond_to do |format|
      format.html do
        @search_query = parameters[:q]
        if @search_query.present?
          batched_results = Services.rummager.batch_search([answer_query, topic_query])["results"]
          answer_results = batched_results.first["results"]
          topic_results = batched_results.second["results"]
          @answer = AnswerSearch::Answer.new(@search_query, answer_results).find
          @results = TopicSearch::Presenter.new(@search_query, topic_results, topic_taxonomy).results
        else
          @answer = nil
          @results = []
        end
      end
    end
  end

private

  def answer_query
    AnswerSearch::QueryBuilder.new.call(@search_query, organisations: organisations)
  end

  def topic_query
    TopicSearch::QueryBuilder.new.call(@search_query)
  end

  def parameters
    params.permit(:q)
  end

  def organisations
    Services.registries.all["organisations"].organisations.values
  end

  def topic_taxonomy
    Services.registries.all["part_of_taxonomy_tree"]
  end

  def hide_search_box
    set_slimmer_headers(remove_search: true)
  end
end
