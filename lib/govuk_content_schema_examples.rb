# Include this module to get access to the GOVUK Content Schema examples in the
# tests.
#
# By default, the govuk-content-schemas repository is expected to be located
# at ../govuk-content-schemas. This can be overridden with the
# GOVUK_CONTENT_SCHEMAS_PATH environment variable, for example:
#
#   $ GOVUK_CONTENT_SCHEMAS_PATH=/some/dir/govuk-content-schemas bundle exec rake
#
require 'gds_api/test_helpers/content_store'

module GovukContentSchemaExamples
  extend ActiveSupport::Concern

  class Examples
    attr_reader :path, :supported_formats

    def initialize(path = nil, supported_formats = %w{finder})
      @path = path || default_path
      @supported_formats = supported_formats
      validate_path!
    end

    def get(name)
      govuk_content_schema_examples[name]
    end

  private
    def validate_path!
      unless Dir.exists?(path)
        raise "Could not find govuk-content-schemas in '#{path}'. Make sure it is present to run test suite."
      end
    end

    def govuk_content_schema_examples
      all_govuk_content_schema_examples.each_with_object({}) do |(filename, data), hash|
        hash[filename] = data if supported_format?(data)
      end
    end

    def all_govuk_content_schema_examples
      @all_govuk_content_schema_examples ||= govuk_content_schema_example_files.each_with_object({}) do |file_path, hash|
        filename = File.basename(file_path)
        hash[filename] = JSON.parse(File.read(file_path))
      end
    end

    def govuk_content_schema_example_files
      Dir.glob Rails.root.join(path).join("formats/*/frontend/examples/*.json")
    end

    def default_path
      ENV['GOVUK_CONTENT_SCHEMAS_PATH'] || '../govuk-content-schemas'
    end

    def supported_format?(data)
      supported_formats.include?(data['format'])
    end
  end

  included do
    include GdsApi::TestHelpers::ContentStore

    # Returns a hash representing an example content item from govuk-content-schemas
    def govuk_content_schema_example(name)
      Examples.new.get(name + '.json')
    end
  end
end
