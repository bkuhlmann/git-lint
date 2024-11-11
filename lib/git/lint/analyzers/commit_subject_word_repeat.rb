# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit subject for repeated words.
      class CommitSubjectWordRepeat < Abstract
        include Dependencies[validator: "validators.repeated_word"]

        def valid? = validator.call(commit.subject).empty?

        def issue
          return {} if valid?

          {hint: "Avoid repeating these words: #{validator.call commit.subject}."}
        end
      end
    end
  end
end
