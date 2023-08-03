# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit bodies with only a single bullet point.
      class CommitBodyBulletOnly < Abstract
        def valid? = !affected_commit_body_lines.one?

        def issue
          return {} if valid?

          {
            hint: "Use paragraph instead of single bullet.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new configuration.commits_body_bullet_only_includes
        end

        def invalid_line?(line) = line.match?(/\A#{Regexp.union filter_list}\s+/)
      end
    end
  end
end
