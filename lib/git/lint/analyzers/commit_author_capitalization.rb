# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes author for proper capitalization of author name.
      class CommitAuthorCapitalization < Abstract
        def initialize commit, validator: Validators::Capitalization, **dependencies
          super commit, **dependencies
          @validator = validator
        end

        def valid? = validator.new(commit.author_name).valid?

        def issue
          return {} if valid?

          {hint: %(Capitalize each part of name: "#{commit.author_name}".)}
        end

        private

        attr_reader :validator
      end
    end
  end
end
