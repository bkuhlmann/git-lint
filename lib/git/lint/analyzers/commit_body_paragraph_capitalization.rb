# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes proper capitalization of commit body paragraphs.
      class CommitBodyParagraphCapitalization < Abstract
        def self.invalid?(line) = line.match?(/\A[[:lower:]].+\Z/m)

        def valid? = lowercased_lines.empty?

        def issue
          return {} if valid?

          {
            hint: "Capitalize first word.",
            lines: affected_lines
          }
        end

        private

        def lowercased_lines = commit.body_paragraphs.select { |line| self.class.invalid? line }

        def affected_lines
          klass = self.class

          commit.body_paragraphs.each.with_object([]).with_index do |(line, lines), index|
            lines << klass.build_issue_line(index, line) if klass.invalid? line
          end
        end
      end
    end
  end
end
