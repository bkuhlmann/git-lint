# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes pretense of commit body.
      class CommitBodyPresence < Abstract
        using ::Refinements::Strings

        def valid?
          return true if commit.fixup?

          valid_lines = commit.body_lines.grep_v(/^\s*$/)
          valid_lines.size >= minimum
        end

        def minimum = settings.minimum

        def issue
          return {} if valid?

          {hint: %(Use minimum of #{"#{minimum} line".pluralize "s", count: minimum} (non-empty).)}
        end
      end
    end
  end
end
