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
            length: 72
          }
        end

        def valid? = commit.subject.sub(/(fixup!|squash!)\s{1}/, "").size <= length

        def issue
          return {} if valid?

          {hint: "Use #{length} characters or less."}
        end

        private

        def length = settings.fetch(:length)
      end
    end
  end
end
