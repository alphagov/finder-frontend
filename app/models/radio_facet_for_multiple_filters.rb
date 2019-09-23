class RadioFacetForMultipleFilters < FilterableFacet
  attr_reader :value
  def initialize(facet, value, filter_hashes)
    @filter_hashes = filter_hashes
    @value = validated_value(value, @filter_hashes)
    super(facet)
  end

  def options
    @filter_hashes.map do |filter_hash|
      {
        value: filter_hash["value"],
        text: filter_hash["label"],
        checked: @value == filter_hash["value"],
      }
    end
  end

  def has_filters?
    true
  end

  def sentence_fragment
    nil
  end

  def query_params
    { key => @value }
  end

  def to_partial_path
    "radio_facet"
  end

  def allowed_values
    @filter_hashes
  end

private

  attr_reader :filter_hashes

  def validated_value(value, filter_hashes)
    filter_hashes.map { |f| f["value"] }.include?(value) ? value : default_value
  end

  def default_value
    @filter_hashes.find { |hash_hash| hash_hash["default"] }.fetch("value")
  end
end
