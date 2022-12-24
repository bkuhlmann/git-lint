# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator duplication.
      class CommitTrailerCollaboratorDuplication < Abstract
        include Import[pattern: "trailers.collaborator"]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Avoid duplication.",
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? trailer
          trailer.key.match?(pattern) && commit.trailers.tally[trailer] != 1
        end
      end
    end
  end
end
