# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit subject length is short and concise.
      class CommitSubjectLength < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            maximum: 72
          }
        end

        def valid? = commit.subject.sub(/(fixup!|squash!)\s{1}/, "").size <= maximum

        def issue
          return {} if valid?

          {hint: "Use #{maximum} characters or less."}
        end

        private

        def maximum = settings.fetch(:maximum)
      end
    end
  end
end
