module AnswerSearch
  class Answer
    def initialize(search_query, search_results)
      @term = search_query
      @results = search_results
    end

    def find
      return unless results.count > 1 && term.present?

      score_difference = results.first["es_score"] / results.second["es_score"]
      score_threshold = 2.135 # 2.135 is median of top 500 results difference
      cleaned_query = clean(term)
      first_result_link = clean(results.first["link"])
      first_result_lev_distance = LevenshteinDistance.compute(cleaned_query, first_result_link)
      if (score_difference > score_threshold) || (first_result_lev_distance < 0.5)
        return results.first
      end

      nil
    end

  private

    attr_accessor :term, :results

    def clean(link)
      result = []
      link.split("/").last.gsub("-", " ").downcase.split(" ").each do |word|
        word = word.stem
        unless stop_word?(word)
          result << word.stem
        end
      end
      result.join(" ")
    end

    def stop_word?(word)
      Rails.configuration.stop_words.has_key? word
    end
  end
end
