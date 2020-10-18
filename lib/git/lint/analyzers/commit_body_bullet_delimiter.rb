# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitBodyBulletDelimiter < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            includes: %w[\\-]
          }
        end

        def valid?
          commit.body_lines.none? { |line| invalid_line? line }
        end

        def issue
          return {} if valid?

          {
            hint: "Use space after bullet.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.fetch :includes
        end

        def invalid_line? line
          line.match?(/\A\s*#{pattern}(?!(#{pattern}|\s)).+\Z/)
        end

        def pattern
          Regexp.union filter_list.to_regexp
        end
      end
    end
  end
end
