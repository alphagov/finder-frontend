module AnswerSearch
  class LevenshteinDistance
    def self.compute(word_one, word_two)
      return 1 unless word_one.is_a?(String) && word_two.is_a?(String)

      distance = Levenshtein.distance(word_one, word_two)
      max_distance = [word_one.length, word_two.length].max.to_f
      min = 0.0
      max = 1.0
      ((distance - min) / (max_distance - min) * (max - min) + min)
    end
  end
end
