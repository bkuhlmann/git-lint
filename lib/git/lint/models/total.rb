# frozen_string_literal: true

module Git
  module Lint
    module Models
      # Models totals for reporting purposes.
      Total = Data.define :items, :issues, :warnings, :errors do
        def initialize items: 0, issues: 0, warnings: 0, errors: 0
          super
        end

        def empty? = items.zero?

        def issues? = issues.positive?

        def warnings? = warnings.positive?

        def errors? = errors.positive?
      end
    end
  end
end
