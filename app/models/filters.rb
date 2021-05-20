module Filters
  class ResearchAndStatsHashes
    def call
      [
        {
          "value" => "all_research_and_statistics",
          "label" => "All research and statistics",
          "filter" => {
            "content_store_document_type" => %w[
              independent_report
              national_statistics
              official_statistics
              research
              research_for_development_output
              statistical_data_set
              statistics
              statistics_announcement
            ],
          },
          "default" => true,
        },
        {
          "value" => "statistics_published",
          "label" => "Statistics (published)",
          "filter" => {
            "content_store_document_type" => %w[
              national_statistics
              official_statistics
              statistical_data_set
              statistics
            ],
          },
        },
        {
          "value" => "upcoming_statistics",
          "label" => "Statistics (upcoming)",
          "filter" => {
            "format" => %w[statistics_announcement],
            "release_timestamp" => "from:#{Time.zone.today}",
          },
        },
        {
          "value" => "cancelled_statistics",
          "label" => "Statistics (cancelled)",
          "filter" => {
            "statistics_announcement_state" => "cancelled",
          },
        },
        {
          "value" => "research",
          "label" => "Research",
          "filter" => {
            "content_store_document_type" => %w[
              independent_report
              research
              research_for_development_output
            ],
          },
        },
      ]
    end
  end

  class OfficialDocumentsHashes
    def call
      [
        {
          "value" => "command_or_act_papers",
          "label" => "Command or act papers",
          "filter" => {
            "has_official_document" => true,
          },
          "default" => true,
        },
        {
          "value" => "command_papers",
          "label" => "Command papers only",
          "filter" => {
            "has_command_paper" => true,
            "has_act_paper" => false,
          },
        },
        {
          "value" => "act_papers",
          "label" => "Act papers only",
          "filter" => {
            "has_act_paper" => true,
            "has_command_paper" => false,
          },
        },
      ]
    end
  end
end
