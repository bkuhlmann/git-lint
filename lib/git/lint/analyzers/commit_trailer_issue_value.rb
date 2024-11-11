# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer issue value.
      class CommitTrailerIssueValue < Abstract
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

        def load_filter_list
          Kit::FilterList.new settings.commits_trailer_issue_value_includes
        end

        def invalid_line? trailer
          trailer.key.match?(setting.pattern) && !trailer.value.match?(value_pattern)
        end

        def value_pattern = /\A#{Regexp.union filter_list}\Z/
      end
    end
  end
end
