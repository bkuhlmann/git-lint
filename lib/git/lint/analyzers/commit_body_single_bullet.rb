# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitBodySingleBullet < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            includes: %w[\\-]
          }
        end

        def valid? = affected_commit_body_lines.size != 1

        def issue
          return {} if valid?

          {
            hint: "Use paragraph instead of single bullet.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list = Kit::FilterList.new(settings.fetch(:includes))

        def invalid_line?(line) = line.match?(/\A#{Regexp.union filter_list.to_regexp}\s+/)
      end
    end
  end
end
