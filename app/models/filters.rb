module Filters
  def self.research_and_statistics_filters
    [
      {
        'key' => 'upcoming_statistics',
        'label' => 'Statistics (upcoming)',
        'filter' => {
          'release_timestamp' => "from:#{Date.today.iso8601}",
          'format' => %w(statistics_announcement)
        }
      },
      {
        'key' => 'published_statistics',
        'label' => 'Statistics (published)',
        'filter' => {
          'content_store_document_type' => %w(statistics national_statistics statistical_data_set official_statistics)
        },
        'default' => true
      },
      {
        'key' => 'research',
        'label' => 'Research',
        'filter' => {
          'content_store_document_type' => %w(dfid_research_output independent_report research)
        }
      }
    ]
  end
end
