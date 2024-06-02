# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer reviewer value.
      class CommitTrailerReviewerValue < Abstract
        include Import[setting: "trailers.reviewer"]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Use: #{filter_list.to_usage "or"}.",
            lines: affected_commit_trailers
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.commits_trailer_reviewer_value_includes
        end

        def invalid_line? trailer
          trailer.key.match?(setting.pattern) && !trailer.value.match?(value_pattern)
        end

        def value_pattern = /\A#{Regexp.union filter_list}\Z/
      end
    end
  end
end
