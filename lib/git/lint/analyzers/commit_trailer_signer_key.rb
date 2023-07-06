# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer signer key usage.
      class CommitTrailerSignerKey < Abstract
        include Import[setting: "trailers.signer"]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Use format: #{filter_list.to_usage}.",
            lines: affected_commit_trailers
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new setting.name
        end

        def invalid_line? trailer
          trailer.key.then do |key|
            key.match?(setting.pattern) && !key.match?(/\A#{Regexp.union filter_list}\Z/)
          end
        end
      end
    end
  end
end
