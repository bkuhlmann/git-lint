# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitBodyLeadingLine < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error
          }
        end

        def valid?
          raw_body = commit.raw_body
          subject, body = raw_body.split "\n", 2
          return true if !String(subject).empty? && String(body).strip.empty?

          raw_body.match?(/\A.+\n\n.+/)
        end

        def issue
          return {} if valid?

          {hint: "Use blank line between subject and body."}
        end
      end
    end
  end
end
