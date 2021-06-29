# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitAuthorCapitalization < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error
          }
        end

        def initialize commit:, settings: self.class.defaults, validator: Validators::Capitalization
          super commit: commit, settings: settings
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
