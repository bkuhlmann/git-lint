# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes use of commit body phrases that are not informative.
      class CommitBodyPhrase < Abstract
        def valid? = commit.body_lines.all? { |line| !invalid_line? line }

        def issue
          return {} if valid?

          {
            hint: %(Avoid: #{filter_list.to_hint}.),
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list = Kit::FilterList.new(settings.excludes)

        def invalid_line? line
          line.downcase.match? Regexp.new(
            Regexp.union(filter_list.to_regexp).source,
            Regexp::IGNORECASE
          )
        end
      end
    end
  end
end
