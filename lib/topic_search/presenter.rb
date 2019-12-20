require "fast_stemmer"
require "kmeans-clusterer"

module TopicSearch
  class Presenter
    attr_accessor :tree, :top_level_results, :second_level_results

    def initialize(search_query, search_results, taxonomy_tree)
      @q = search_query
      @results = search_results
      @taxonomy_tree = taxonomy_tree
    end

    def results
      build_taxon_tree
      calculate_metrics
      build_results
      @results
    end

  private

    attr_reader :taxonomy_tree

    def build_taxon_tree
      @scorer = TopicSearch::ScoreQueryBuilder.new(@q)
      # creates root: @tree is always the root node/taxon.
      @tree = TaxonNode.new({ content_id: "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a" }, @scorer)
      @results.each do |result|
        result.fetch("taxons", []).each { |id|
          taxon = taxonomy_tree.get_taxon(id)
          build_taxon_branch(taxon) if taxon
        }
      end
    end

    def build_taxon_branch(taxon)
      # Get all taxons tagged betwen this and root taxon
      # Adds these in reverse order as child nodes of their parent node
      # Makes the topmost node the child of the root node.
      ancestors = [taxon]
      loop do
        parent = ancestors.last.dig("parent")
        if parent.nil?
          break
        else
          ancestors << taxonomy_tree.get_taxon(parent)
        end
      end

      last_taxon = @tree
      ancestors.reverse.each do |child|
        last_taxon = last_taxon.add_child(TaxonNode.new(child, @scorer))
      end
    end

    def build_results
      @results = []

      top_level_taxons = build_top_level_taxons
      transform, mean_log = calculate_mean_log(top_level_taxons)

      all_second_level_scores = []
      top_level_taxons.each do |top_level_taxon|
        top_level_taxon.build_second_level_taxons(transform, mean_log)
        all_second_level_scores += top_level_taxon.second_level_content_page_scores
      end

      # Some maths for some reason?
      transform = 0
      mean_log = 0
      if all_second_level_scores.any?
        k = 2
        data = []
        all_second_level_scores.sort!
        all_second_level_scores.sort.each_with_index do |score, _index|
          data << [Math.log10(score), Math.log10(score)]
        end
        kmeans = KMeansClusterer.run(k, data, labels: all_second_level_scores, runs: 5)
        centroids = kmeans.clusters.map { |cluster| cluster.centroid.to_a.first }
        mean_log = centroids.min
      end

      # Remove any low-scoring results
      top_level_taxons.each do |top_level_taxon|
        top_level_taxon.filter_second_level_taxon_pages(transform, mean_log)
        @results << top_level_taxon.to_h
      end
    end

    def build_top_level_taxons
      top_level_taxons = []
      @tree.ranked_children.each do |top_level_taxon|
        top_level_taxons << TopLevelResult.new(@q, top_level_taxon)
      end
      top_level_taxons
    end

    def calculate_mean_log(top_level_taxons)
      all_children = top_level_taxons.inject([]) { |children, top_level_taxon| children += top_level_taxon.all_children_ranked; children }
      scores = all_children.inject([]) { |accum, taxon_node| accum << taxon_node.score; accum }
      if scores.any?
        scores.median_log
      else
        0
      end
    end

    def calculate_metrics
      @scorer.batch_score(@tree)
      @tree.calculate_metrics(@q)
    end

    def print
      @tree.print(@q)
    end
  end
end

# TODO: Find out what these monkey patches are doing; replace them.
module Enumerable
  def sum
    self.compact.inject(0) { |accum, i| accum + i }
  end

  def mean
    self.sum / self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0) { |accum, i| accum + (i - m)**2 }
    sum / (self.length - 1).to_f
  end

  def standard_deviation
    Math.sqrt(self.sample_variance)
  end

  def median
    sorted = self.compact.sort
    len = self.compact.count
    return 0 unless sorted.any?

    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def standard_error_of_mean
    self.standard_deviation / Math.sqrt(self.length)
  end

  def median_transform
    (self.median - self.standard_error_of_mean).abs
  end

  def median_transform_twice_std
    (self.median.abs - (self.standard_error_of_mean * 2.5).abs).abs
  end

  def median_log
    logs = self.compact.map { |value| value }
    sorted_logs = logs.sort
    transform = sorted_logs.first.abs
    absolute_sorted_logs = sorted_logs.map { |value| value + transform }
    [transform, absolute_sorted_logs.median]
  end
end


class Numeric
  def transform_mean_log(transform)
    return transform unless self.positive?

    Math.log10(self) + transform
  end
end
