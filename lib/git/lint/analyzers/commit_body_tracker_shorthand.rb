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
            hint: "Explain issue instead of using shorthand. Avoid: #{filter_list.to_hint}.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list = Kit::FilterList.new(settings.excludes)

        def invalid_line?(line) = line.match?(/.*#{Regexp.union filter_list.to_regexp}.*/)
      end
    end
  end
end
