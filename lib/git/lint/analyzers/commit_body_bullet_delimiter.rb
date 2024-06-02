# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit body delimiter usage.
      class CommitBodyBulletDelimiter < Abstract
        def valid? = commit.body_lines.none? { |line| invalid_line? line }

        def issue
          return {} if valid?

          {
            hint: "Use space after bullet.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.commits_body_bullet_delimiter_includes
        end

        def invalid_line?(line) = line.match?(/\A\s*#{pattern}(?!(#{pattern}|\s)).+\Z/)

        def pattern = Regexp.union filter_list
      end
    end
  end
end
