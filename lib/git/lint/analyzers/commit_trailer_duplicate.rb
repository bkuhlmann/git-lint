# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer duplicate.
      class CommitTrailerDuplicate < Abstract
        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Avoid duplicates.",
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line?(trailer) = commit.trailers.tally[trailer] != 1
      end
    end
  end
end
