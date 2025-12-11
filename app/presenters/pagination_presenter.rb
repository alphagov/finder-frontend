# The PaginationPresenter class is responsible for creating the next and
# previous links to be displayed on finders.
class PaginationPresenter
  include ActiveSupport::NumberHelper

  def initialize(per_page:, start_offset:, total_results:, url_builder:)
    @per_page = per_page
    @start_offset = start_offset
    @total_results = total_results
    @url_builder = url_builder
  end

  def next_and_prev_links
    return unless can_paginate?

    { previous_page:, next_page: }.compact
  end

private

  attr_reader :per_page, :start_offset, :total_results, :url_builder

  def can_paginate?
    per_page.present? && has_other_pages?
  end

  def has_other_pages?
    previous_page.present? || next_page.present?
  end

  def page_links
    { previous_page:, next_page: }.compact
  end

  def current_page
    (start_offset / per_page) + 1
  end

  def total_pages
    (total_results / per_page.to_f).ceil
  end

  def next_page
    return unless current_page < total_pages

    build_page_link("Next page", current_page + 1)
  end

  def previous_page
    return unless current_page > 1

    build_page_link("Previous page", current_page - 1)
  end

  def build_page_link(page_label, page)
    {
      title: page_label,
      label: "#{number_to_delimited(page)} of #{number_to_delimited(total_pages)}",
      href: url_builder.url(page:),
    }
  end
end
