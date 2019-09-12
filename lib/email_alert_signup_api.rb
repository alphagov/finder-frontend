require "addressable/uri"

class EmailAlertSignupAPI
  def initialize(applied_filters:, default_filters:, facets:, subscriber_list_title:, finder_format:, default_frequency: nil, email_filter_by: nil)
    @applied_filters = applied_filters.deep_symbolize_keys
    @default_filters = default_filters.deep_symbolize_keys
    @facets = facets
    @subscriber_list_title = subscriber_list_title
    @finder_format = finder_format
    @default_frequency = default_frequency
    @email_filter_by = email_filter_by
  end

  def signup_url
    if @default_frequency
      add_url_param(subscriber_list["subscription_url"], default_frequency: @default_frequency)
    else
      subscriber_list["subscription_url"]
    end
  end

private

  attr_reader :applied_filters, :default_filters, :facets, :subscriber_list_title, :finder_format, :email_filter_by

  def add_url_param(url, param)
    # this method safely adds a URL parameter using the correct one of '?' or '&'
    parsed_uri = Addressable::URI.parse(url)
    parsed_uri.query_values = (parsed_uri.query_values || {}).merge(param)
    parsed_uri.to_s
  end

  def subscriber_list
    Services.email_alert_api.find_or_create_subscriber_list(subscriber_list_options).dig("subscriber_list")
  end

  def subscriber_list_options
    options = { "title" => subscriber_list_title }
    if facet_groups? #business readiness legacy
      options["links"] = facet_groups
    elsif facet_values? #business readiness
      options["links"] = facet_values
    elsif link_based_subscriber_list?
      options["links"] = links
    else
      options["tags"] = tags
    end
    options
  end

  def link_based_subscriber_list?
    content_types = %w[organisations people world_locations part_of_taxonomy_tree]
    keys = facet_filter_keys.map { |key| key.gsub(/^(all_|any_)/, "") }
    (keys & content_types).present?
  end

  def links
    selected_keys = applied_filters.keys.map(&:to_s) & facet_filter_keys
    filter_links = selected_keys.each_with_object({}) do |full_key, result|
      operator, key = split_key(full_key)
      values = Array.wrap(applied_filters[full_key.to_sym])
      result[key] ||= {}
      result[key][operator] = to_content_ids(key, values)
    end
    filter_links.merge(default_links)
  end

  def default_links
    default_filters.transform_values { |value| { any: Array.wrap(value) } }
  end

  def split_key(full_key)
    matches = full_key.match(/^((?<operator>any|all)_)?(?<key>.*)$/)
    operator = matches[:operator] || "any"
    key = matches[:key] == "part_of_taxonomy_tree" ? "taxon_tree" : matches[:key]
    [operator, key]
  end

  def to_content_ids(key, values)
    return values unless %w[organisations people world_locations].include?(key)

    registry = Registries::BaseRegistries.new.all[key]
    values.map { |value| registry[value]["content_id"] }
  end

  def facet_filter_keys
    @facet_filter_keys ||= facets.map { |f| f["filter_key"] || f["facet_id"] }
  end

  def facet_groups?
    facets.any? { |facet| facet["facet_id"] == "facet_groups" }
  end

  def facet_groups
    facet_groups = facets.map do |facet|
      facet["facet_choices"].map do |facet_choice|
        facet_choice["key"]
      end
    end

    { "facet_groups" => { any: facet_groups.flatten } }
  end

  def facet_values?
    email_filter_by == "facet_values"
  end

  def facet_values
    @facet_values ||= filter_keys.each_with_object({}) { |key, links_hash|
      values = values_for_key(key)
      links_hash["facet_values"] ||= {}
      links_hash["facet_values"][:any] ||= []
      links_hash["facet_values"][:any] = links_hash.dig("facet_values", :any).concat(values).uniq
    }
  end

  def tags
    return filters_to_tags if finder_format.blank?

    filters_to_tags.merge(format: { any: [finder_format] })
  end

  def filters_to_tags
    @filters_to_tags ||= filter_keys.each_with_object({}) { |key, tags_hash|
      values = values_for_key(key)
      any_or_all = is_all_field?(key) ? :all : :any
      tag = is_all_field?(key) ? key[4..-1] : key

      tags_hash[tag] ||= {}
      tags_hash[tag][any_or_all] ||= []
      tags_hash[tag][any_or_all] = tags_hash.dig(tag, any_or_all).concat(values).uniq
    }
  end

  def filter_keys
    applied_filter_keys = applied_filters.keys.reject { |key| facet_by_key(key).nil? }
    applied_filter_keys.concat(default_filters.keys).uniq
  end

  def values_for_key(key)
    applied_values = Array(applied_filters[key])
    default_values = Array(default_filters[key])
    facet = facet_by_key(key) || {}

    facet_choice_values = facet_choice_filter_values(facet, applied_values)
    values = facet_choice_values.any? ? facet_choice_values : applied_values

    values.concat(default_values)
  end

  def facet_choice_filter_values(facet, values)
    facet
      .fetch("facet_choices", [])
      .select { |option| values.include?(option["key"]) }
      .flat_map { |option| option["filter_values"] }
  end

  def facet_by_key(key)
    facets.find { |facet| [facet["filter_key"], facet["facet_id"]].include?(key.to_s) }
  end

  def is_all_field?(key)
    key[0..3] == "all_"
  end
end
