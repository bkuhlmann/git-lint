# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes proper capitalization of commit body paragraphs.
      class CommitBodyParagraphNewLine < Abstract
        PATTERN = /
          \n      # New line.
          (?!     # Negative lookahead start.
          \s{1,}  # Indentation.
          |       # Or.
          \s*     # Optional whitespace.
          \#      # Comment character.
          )       # Negative lookahead end.
        /mx

        def initialize(commit, pattern: PATTERN, **)
          super(commit, **)
          @pattern = pattern
        end

        def valid? = invalids.empty?

        def issue
          return {} if valid?

          {
            hint: "Avoid unnecessary new lines.",
            lines: affected_lines
          }
        end

        private

        attr_reader :pattern

        def affected_lines
          invalids.each.with_object [] do |line, lines|
            lines << self.class.build_issue_line(commit.body_lines.index(line[/.+/]), line)
          end
        end

        def invalids
          @invalids ||= commit.body_paragraphs.grep pattern
        end
      end
    end
  end
end
