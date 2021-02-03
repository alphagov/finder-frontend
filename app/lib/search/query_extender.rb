
require "damerau-levenshtein"
# This was an early idea about how the code could be used in Ruby
# It was since rewritten as frontend code in Javascript but shows
# how similar logic could be implemented in the backend

module Search
  class QueryExtender

    def initialize(search_term)
      @search_term = search_term
    end

    def extensions
      @extensions ||= begin
        extensions = fetch_verb_extensions
        return extensions unless extensions.empty?
        fetch_object_extensions
      end
    end

    def self.verb_extensions
      @@verb_extensions ||= begin
        JSON.parse(File.open("verbs.json").read)
      end
    end

    def self.object_extensions
      @@object_extensions ||= begin
        JSON.parse(File.open("objects.json").read)
      end
    end

  private
    attr_accessor :search_term

    def fetch_verb_extensions
      return present(verb_extensions.fetch(search_term, [])) if verb_extensions.keys.include?(search_term)
      closest_match(search_term, verb_extensions)
    end

    def closest_match(word, possible_matches)
      smallest_distance = word.length / 2
      result = nil
      possible_matches.each_pair do |possible_match, values|
        distance = DamerauLevenshtein.distance(word, possible_match)
        if distance < smallest_distance
          smallest_distance = distance
          result = values
        end
      end
      if result
        return values
      end
      []
    end

    def fetch_object_extensions
      return present(object_extensions.fetch(search_term, [])) if object_extensions.keys.include?(search_term)
      closest_match(search_term, object_extensions)
    end

    def present(extensions)
      extensions.map { |extension| { title: extension[0] }}
    end
  end
end
