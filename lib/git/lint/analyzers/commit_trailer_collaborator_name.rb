# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator name construction.
      class CommitTrailerCollaboratorName < Abstract
        include Import[
          pattern: "trailers.collaborator",
          parser: "parsers.person",
          validator: "validators.name"
        ]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Name must follow key and consist of #{minimum} parts (minimum).",
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? trailer
          parser.call(trailer.value).then do |person|
            trailer.key.match?(pattern) && !validator.call(person.name, minimum:)
          end
        end

        private

        def minimum = settings.minimum
      end
    end
  end
end
