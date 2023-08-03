# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes body tracker shorthand usage.
      class CommitBodyTrackerShorthand < Abstract
        def valid? = commit.body_lines.none? { |line| invalid_line? line }

        def issue
          return {} if valid?

          {
            hint: "Explain issue instead of using shorthand. Avoid: #{filter_list.to_usage}.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new configuration.commits_body_tracker_shorthand_excludes
        end

        def invalid_line?(line) = line.match?(/.*#{Regexp.union filter_list}.*/)
      end
    end
  end
end
