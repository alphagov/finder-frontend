require 'gds_api/finder_api'

class FinderApi
  attr_reader :slug, :api

  def initialize(slug)
    @slug = slug
    @api = GdsApi::FinderApi.new(Plek.current.find('finder-api'))
  end

  def get_schema
    {
      'slug' => 'cma-cases',
      'name' => 'Competition and Markets Authority cases',
      'facets' => [
        {
          'type' => 'select',
          'name' => 'Case type',
          'key' => 'case_type',
          'allowed_values' => [
            {'label' => 'Airport price control reviews',            'value' => 'airport-price-control-reviews'},
            {'label' => 'Market investigations',                    'value' => 'market-investigations'},
            {'label' => 'Remittals',                                'value' => 'remittals'},
            {'label' => 'Telecommunications price control appeals', 'value' => 'telecommunications-price-control-appeals'},
            {'label' => 'Energy code modification appeals',         'value' => 'energy-code-modification-appeals'},
            {'label' => 'Merger inquiries',                         'value' => 'merger-inquiries'},
            {'label' => 'Reviews of undertakings and orders',       'value' => 'reviews-of-undertakings-and-orders'},
            {'label' => 'Water price determinations',               'value' => 'water-price-determinations'}
          ],
          'include_blank' => 'All case types'
        }
      ]
    }
  end

  def get_result_set(params)
    api.get_documents(slug, params)
  end
end
