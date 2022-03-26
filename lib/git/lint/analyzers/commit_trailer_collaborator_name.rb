# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator name construction.
      class CommitTrailerCollaboratorName < Abstract
        # rubocop:disable Metrics/ParameterLists
        def initialize commit,
                       parser: Parsers::Trailers::Collaborator,
                       validator: Validators::Name,
                       **dependencies
          super commit, **dependencies
          @parser = parser
          @validator = validator
        end
        # rubocop:enable Metrics/ParameterLists

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Name must follow key and consist of #{minimum} parts (minimum).",
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? line
          collaborator = parser.new line
          collaborator.match? && !validator.new(collaborator.name.strip, minimum:).valid?
        end

        private

        attr_reader :parser, :validator

        def minimum = settings.minimum
      end
    end
  end
end
