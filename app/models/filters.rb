# typed: true
module Filters
  class ResearchAndStatsHashes
    def call
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

  class OfficialDocumentsHashes
    def call
      [
        {
          'key' => 'command_or_act_papers',
          'label' => 'Command or act papers',
          'filter' => {
            'has_official_document' => true
          },
            'default' => true
        },
        {
          'key' => 'command_papers',
          'label' => 'Command papers only',
          'filter' => {
            'has_command_paper' => true,
            'has_act_paper' => false
          }
        },
        {
          'key' => 'act_papers',
          'label' => 'Act papers only',
          'filter' => {
            'has_act_paper' => true,
            'has_command_paper' => false
          }
        }
      ]
    end
  end
end
