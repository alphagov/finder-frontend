# This unfortunate monkey patch adds support for ostruct-responses to GdsApi::Response.
# This was removed from gds-api-adapters in https://github.com/alphagov/gds-api-adapters/pull/622
# for good reasons, but this apps seems to be using it so much that it's unfeasible
# at the moment to update the code to use hashes.
require 'ostruct'

module GdsApi
  class Response
    def to_ostruct
      @ostruct ||= self.class.build_ostruct_recursively(parsed_content)
    end

    def self.build_ostruct_recursively(value)
      case value
      when Hash
        OpenStruct.new(Hash[value.map { |k, v| [k, build_ostruct_recursively(v)] }])
      when Array
        value.map { |v| build_ostruct_recursively(v) }
      else
        value
      end
    end
  end
end
