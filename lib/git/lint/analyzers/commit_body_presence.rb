# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitBodyPresence < Abstract
        using Refinements::Strings

        def self.defaults
          {
            enabled: true,
            severity: :warn,
            minimum: 1
          }
        end

        def valid?
          return true if commit.fixup?

          valid_lines = commit.body_lines.reject { |line| line.match?(/^\s*$/) }
          valid_lines.size >= minimum
        end

        def minimum = settings.fetch(:minimum)

        def issue
          return {} if valid?

          {hint: %(Use minimum of #{"line".pluralize count: minimum} (non-empty).)}
        end
      end
    end
  end
end
