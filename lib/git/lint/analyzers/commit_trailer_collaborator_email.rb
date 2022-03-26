# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator email address format.
      class CommitTrailerCollaboratorEmail < Abstract
        # rubocop:disable Metrics/ParameterLists
        def initialize commit,
                       parser: Parsers::Trailers::Collaborator,
                       validator: Validators::Email,
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
            hint: %(Email must follow name and use format: "<name@server.domain>".),
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? line
          collaborator = parser.new line
          collaborator.match? && !validator.new(collaborator.email).valid?
        end

        private

        attr_reader :parser, :validator
      end
    end
  end
end
