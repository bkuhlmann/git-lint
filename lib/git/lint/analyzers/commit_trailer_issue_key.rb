# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer issue key usage.
      class CommitTrailerIssueKey < Abstract
        include Dependencies[setting: "trailers.issue"]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Use format: #{filter_list.to_usage}.",
            lines: affected_commit_trailers
          }
        end

        protected

        def load_filter_list = Kit::FilterList.new setting.name

        def invalid_line? trailer
          trailer.key.then do |key|
            key.match?(setting.pattern) && !key.match?(/\A#{Regexp.union filter_list}\Z/)
          end
        end
      end
    end
  end
end
