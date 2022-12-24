# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes author for proper capitalization of author name.
      class CommitAuthorCapitalization < Abstract
        include Import[validator: "validators.capitalization"]

        def valid? = validator.new(commit.author_name).valid?

        def issue
          return {} if valid?

          {hint: %(Capitalize each part of name: "#{commit.author_name}".)}
        end
      end
    end
  end
end
