# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes proper capitalization of commit body paragraphs.
      class CommitBodyParagraphCapitalization < Abstract
        PATTERN = /
          \A           # Search start.
          (?!          # Negative lookahead start.
          (?:          # Non-capture group start.
          audio        # Ignore audio.
          |            # Or.
          image        # Ignore image.
          |            # Or.
          video        # Ignore video.
          )            # Non-capture group end.
          ::           # Suffix.
          |            # Or.
          link:        # Ignore link.
          |            # Or.
          xref:        # Ignore xref.
          )            # Negative lookahead end.
          [[:lower:]]  # Match lowercase letters.
          .+           # Match one or more characters.
          \Z           # Search end.
        /mx

        def initialize(commit, pattern: PATTERN, **)
          super(commit, **)
          @pattern = pattern
        end

        def valid? = invalids.empty?

        def issue
          return {} if valid?

          {
            hint: "Capitalize first word.",
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
