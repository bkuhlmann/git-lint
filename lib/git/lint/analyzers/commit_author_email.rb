# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes author email address for proper format.
      class CommitAuthorEmail < Abstract
        include Dependencies[validator: "validators.email"]

        def valid? = validator.call commit.author_email

        def issue
          return {} if valid?

          {hint: %(Use "<name>@<server>.<domain>" instead of "#{commit.author_email}".)}
        end
      end
    end
  end
end
