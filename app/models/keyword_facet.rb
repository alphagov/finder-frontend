class KeywordFacet
  def initialize(keywords = "")
    @keywords = keywords
  end

  def sentence_fragment
    return nil unless has_filters?

    {
      "key" => key,
      "preposition" => "containing",
      "values" => value_fragments,
      "word_connectors" => {
        words_connector: "",
      },
    }
  end

  def has_filters?
    keywords.present?
  end

  def key
    "keywords"
  end

  def value
    [keywords]
  end

  def hide_facet_tag?
    false
  end

  def query_params
    {
      key => value,
    }
  end

private

  attr_reader :keywords

  def value_fragments
    keyword_array = keywords.scan(/".*?"|[^\s]*/)
    keyword_fragments = []

    keyword_array.each do |keyword|
      unless keyword.empty?
        keyword_fragments << {
          "label" => keyword,
          "parameter_key" => key,
          "name" => "keywords",
          "value" => keyword.gsub('"', "&quot;"),
        }
      end
    end

    keyword_fragments
  end
end
