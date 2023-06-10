# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes author name for minimum parts of name.
      class CommitAuthorName < Abstract
        include Import[validator: "validators.name"]

        def valid? = validator.call(commit.author_name, minimum:)

        def issue
          return {} if valid?

          {hint: "Author name must consist of #{minimum} parts (minimum)."}
        end

        private

        def minimum = configuration.commits_author_name_minimum
      end
    end
  end
end
