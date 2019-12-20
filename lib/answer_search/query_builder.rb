module AnswerSearch
  class QueryBuilder
    def call(term, organisations: {})
      {
        count: 2,
        q: term,
        fields: %w(title link),
        filter_organisations: closest_organisation(term, organisations),
        filter_content_purpose_supergroup: guessed_supergroup(term),
      }.compact
    end

  private

    def guessed_supergroup(term)
      tagger = EngTagger.new
      tagged = tagger.add_tags(term)
      has_verbs = (tagger.get_verbs(tagged) || []).any?
      has_verbs ? "services" : nil
    end

    def closest_organisation(search_term, organisations)
      return if search_term.nil?

      lowest_distance = nil
      closest_org = nil

      # This is slow
      search_query = search_term.downcase
      search_words = search_query.split(" ").uniq
      organisations.each do |org|
        org_name = org["title"].downcase
        distances = [LevenshteinDistance.compute(org_name, search_query)]
        distances.concat(search_words.map { |word| LevenshteinDistance.compute(org_name, word) })
        distance = distances.min
        next unless distance < 0.1

        if lowest_distance.nil? || distance < lowest_distance
          lowest_distance = distance
          closest_org = org
        end
      end

      [closest_org["slug"]] if lowest_distance
    end
  end
end
