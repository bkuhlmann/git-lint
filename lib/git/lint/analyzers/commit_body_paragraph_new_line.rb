# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes proper capitalization of commit body paragraphs.
      class CommitBodyParagraphNewLine < Abstract
        PATTERNS = {
          general: /
            \n      # New line.
            (?!     # Negative lookahead start.
            \s{1,}  # Indentation.
            )       # Negative lookahead end.
          /mx,
          markup: /
            \A       # Start of line.
            (        # Start of conditional.
            \s*\#    # Optional whitepace with comment.
            |        # Or.
            `        # Backtick.
            |        # Or.
            -        # Dash.
            |        # Or.
            _        # Underscore.
            |        # Or.
            \+       # Plus.
            |        # Or.
            \d+\.    # Ordered list item.
            |        # Or.
            \.       # Unordered list itme.
            |        # Or.
            \*       # Unordered list itme.
            |        # Or.
            \[.*?\]  # ASCII Doc code block.
            )        # End of conditional.
          /x
        }.freeze

        def initialize(commit, patterns: PATTERNS, **)
          super(commit, **)
          @patterns = patterns
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

        attr_reader :patterns

        def affected_lines
          invalids.each.with_object [] do |line, lines|
            lines << self.class.build_issue_line(commit.body_lines.index(line[/.+/]), line)
          end
        end

        def invalids
          markup = patterns.fetch :markup
          general = patterns.fetch :general

          @invalids ||= commit.body_paragraphs.grep_v(markup).grep general
        end
      end
    end
  end
end
