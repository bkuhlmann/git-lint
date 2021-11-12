# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes author email address for proper format.
      class CommitAuthorEmail < Abstract
        def initialize commit, validator: Validators::Email
          super commit
          @validator = validator
        end

        def valid? = validator.new(commit.author_email).valid?

        def issue
          return {} if valid?

          {hint: %(Use "<name>@<server>.<domain>" instead of "#{commit.author_email}".)}
        end

        private

        attr_reader :validator
      end
    end
  end
end
