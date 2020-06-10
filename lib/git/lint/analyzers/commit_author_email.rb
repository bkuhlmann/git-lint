# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitAuthorEmail < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error
          }
        end

        def initialize commit:, settings: self.class.defaults, validator: Validators::Email
          super commit: commit, settings: settings
          @validator = validator
        end

        def valid?
          validator.new(commit.author_email).valid?
        end

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
