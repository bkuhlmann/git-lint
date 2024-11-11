# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit body for repeated words.
      class CommitBodyWordRepeat < Abstract
        include Dependencies[validator: "validators.repeated_word"]

        def valid? = commit.body_lines.all? { |line| !invalid_line? line }

        def issue
          return {} if valid?

          {
            hint: "Avoid repeating these words: #{validator.call commit.body}.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def invalid_line? line
          return false if line.start_with? "#"

          !validator.call(line).empty?
        end
      end
    end
  end
end
