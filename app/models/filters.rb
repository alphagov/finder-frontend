module Filters
  class ResearchAndStatsHashes
    def call
      [
        {
          'value' => 'upcoming_statistics',
          'label' => 'Statistics (upcoming)',
          'filter' => {
            'release_timestamp' => "from:#{Time.zone.today - 1.month}",
            'format' => %w(statistics_announcement)
          },
          'reject' => {
            'statistics_announcement_state' => 'statistics_published'
          }
        },
        {
          'value' => 'published_statistics',
          'label' => 'Statistics (published)',
          'filter' => {
            'content_store_document_type' => %w(statistics national_statistics statistical_data_set official_statistics)
          },
          'default' => true
        },
        {
          'value' => 'research',
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
          'value' => 'command_or_act_papers',
          'label' => 'Command or act papers',
          'filter' => {
            'has_official_document' => true
          },
            'default' => true
        },
        {
          'value' => 'command_papers',
          'label' => 'Command papers only',
          'filter' => {
            'has_command_paper' => true,
            'has_act_paper' => false
          }
        },
        {
          'value' => 'act_papers',
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
