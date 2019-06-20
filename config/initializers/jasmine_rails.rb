# typed: true
if defined?(JasmineRails)
  module JasmineRails
    class ApplicationController < ActionController::Base
      before_action :skip_slimmer

      def skip_slimmer
        response.headers[Slimmer::Headers::SKIP_HEADER] = "true"
      end
    end
  end
end
