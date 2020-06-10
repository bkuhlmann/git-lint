# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitBodyLineLength < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            length: 72
          }
        end

        def valid?
          commit.body_lines.all? { |line| !invalid_line? line }
        end

        def issue
          return {} if valid?

          {
            hint: "Use #{length} characters or less per line.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def invalid_line? line
          line.length > length
        end

        private

        def length
          settings.fetch :length
        end
      end
    end
  end
end
