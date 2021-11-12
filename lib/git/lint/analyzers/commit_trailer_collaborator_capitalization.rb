# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator name capitalization.
      class CommitTrailerCollaboratorCapitalization < Abstract
        def initialize commit,
                       parser: Parsers::Trailers::Collaborator,
                       validator: Validators::Capitalization
          super commit
          @parser = parser
          @validator = validator
        end

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Name must be capitalized.",
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? line
          collaborator = parser.new line
          collaborator.match? && !validator.new(collaborator.name.strip).valid?
        end

        private

        attr_reader :parser, :validator
      end
    end
  end
end
