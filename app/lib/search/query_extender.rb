

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

    def verb_extensions
      JSON.parse(File.open("verbs.json").read)
    end

    def object_extensions
      JSON.parse(File.open("objects.json").read)
    end

  private
    attr_accessor :search_term

    def fetch_verb_extensions
      present(verb_extensions.fetch(search_term, []))
    end

    def fetch_object_extensions
      present(object_extensions.fetch(search_term, []))
    end

    def present(extensions)
      extensions.map { |extension| { title: extension[0] }}
    end
  end
end
