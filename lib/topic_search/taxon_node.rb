module TopicSearch
  class TaxonNode
    attr_reader :score, :median_child_tf_idf, :content_pages

    def initialize(taxon, scorer)
      @taxon = taxon
      @children = {}
      @scorer = scorer
    end

    def add_child(child_node)
      @children[child_node.id] ||= child_node
      @children[child_node.id]
    end

    def children
      @children.values
    end

    def ranked_children
      children.sort_by { |child| -child.median_child_tf_idf }
    end

    def final_descendants
      return [self.dup] unless children.any?

      children
        .each_with_object([]) { |child, arr|
          arr << child.final_descendants
        }
        .flatten
    end

    def all_descendants
      return [self.dup] unless children.any?

      children
        .each_with_object([]) { |child, arr|
          arr << [self.dup, child.all_descendants]
        }
        .flatten
    end

    def title
      @taxon["title"]
    end

    def href
      @taxon["base_path"]
    end

    def content_id
      @taxon["content_id"]
    end

    def calculate_metrics(query)
      @score ||= fetch_es_score
      scores = [@score]
      children.each do |child|
        child.calculate_metrics(query)
        scores << child.score
      end
      @median_child_tf_idf = scores.median
    end

    def id
      @taxon["content_id"]
    end

    def fetch_es_score
      return -1000 unless id

      scored = @scorer.scores.fetch(id, {})
      @content_pages = scored[:content_pages]
      unless scored[:median_score]
        puts "rummager didn't have response for taxon #{@taxon['title']} #{@taxon['content_id']}"
        return -1000
      end
      scored[:median_score]
    end
  end
end
