# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes author name for minimum parts of name.
      class CommitAuthorName < Abstract
        def initialize commit, validator: Validators::Name, **dependencies
          super commit, **dependencies
          @validator = validator
        end

        def valid? = validator.new(commit.author_name, minimum:).valid?

        def issue
          return {} if valid?

          {hint: "Author name must consist of #{minimum} parts (minimum)."}
        end

        private

        attr_reader :validator

        def minimum = settings.minimum
      end
    end
  end
end
