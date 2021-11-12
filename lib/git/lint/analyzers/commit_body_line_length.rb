# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit body line length to prevent unnecessary horizontal scrolling.
      class CommitBodyLineLength < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            maximum: 72
          }
        end

        def valid? = commit.body_lines.all? { |line| !invalid_line? line }

        def issue
          return {} if valid?

          {
            hint: "Use #{maximum} characters or less per line.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def invalid_line?(line) = line.length > maximum

        private

        def maximum = settings.fetch(:maximum)
      end
    end
  end
end
