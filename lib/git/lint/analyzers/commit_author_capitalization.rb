# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes author name for proper capitalization.
      class CommitAuthorCapitalization < Abstract
        include Import[validator: "validators.capitalization"]

        def valid? = validator.call commit.author_name

        def issue
          return {} if valid?

          {hint: %(Capitalize each part of name: "#{commit.author_name}".)}
        end
      end
    end
  end
end
