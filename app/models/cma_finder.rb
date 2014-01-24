class CMAFinder < Finder
  def initialize
    super(slug: 'cma-cases',
          name: 'Competition and Markets Authority cases',
          facets: [
            SelectFacet.new(name: 'Case type', key: 'case_type', options: [
              ['Airport price control reviews',            'airport-price-control-reviews'],
              ['Market investigations',                    'market-investigations'],
              ['Remittals',                                'remittals'],
              ['Telecommunications price control appeals', 'telecommunications-price-control-appeals'],
              ['Energy code modification appeals',         'energy-code-modification-appeals'],
              ['Merger inquiries',                         'merger-inquiries'],
              ['Reviews of undertakings and orders',       'reviews-of-undertakings-and-orders'],
              ['Water price determinations',               'water-price-determinations']
            ])
          ]
    )
  end
end
