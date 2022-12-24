# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes proper capitalization of commit body paragraphs.
      class CommitBodyParagraphCapitalization < Abstract
        def self.invalid?(line) = line.match?(/\A[[:lower:]].+\Z/m)

        def initialize(...)
          super
          @invalids = commit.body_paragraphs.select { |line| self.class.invalid? line }
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

        attr_reader :invalids

        def affected_lines
          invalids.each.with_object [] do |line, lines|
            lines << self.class.build_issue_line(commit.body_lines.index(line[/.+/]), line)
          end
        end
      end
    end
  end
end
