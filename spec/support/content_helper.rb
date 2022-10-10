# Include this module to get access to the GOVUK Content Schema examples in the
# tests.
require "govuk_schemas/example"
require "gds_api/test_helpers/content_store"

module GovukContentSchemaExamples
  extend ActiveSupport::Concern

  included do
    include GdsApi::TestHelpers::ContentStore

    # Returns a hash representing an finder content item from govuk-content-schemas
    def govuk_content_schema_example(name, format = "finder")
      GovukSchemas::Example.find(format, example_name: name)
    end
  end
end
