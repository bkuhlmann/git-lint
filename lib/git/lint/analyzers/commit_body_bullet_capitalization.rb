# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit body for proper capitalization of bullet sentences.
      class CommitBodyBulletCapitalization < Abstract
        def valid? = lowercased_bullets.size.zero?

        def issue
          return {} if valid?

          {
            hint: "Capitalize first word.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list = Kit::FilterList.new(settings.includes)

        def invalid_line? line
          line.match?(/\A\s*#{Regexp.union filter_list.to_regexp}\s[[:lower:]]+/)
        end

        private

        def lowercased_bullets = commit.body_lines.select { |line| invalid_line? line }
      end
    end
  end
end
