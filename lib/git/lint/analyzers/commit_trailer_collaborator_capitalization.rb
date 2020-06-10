# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitTrailerCollaboratorCapitalization < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error
          }
        end

        # rubocop:disable Metrics/ParameterLists
        def initialize commit:,
                       settings: self.class.defaults,
                       parser: Parsers::Trailers::Collaborator,
                       validator: Validators::Capitalization
          super commit: commit, settings: settings
          @parser = parser
          @validator = validator
        end
        # rubocop:enable Metrics/ParameterLists

        def valid?
          affected_commit_trailer_lines.empty?
        end

        def issue
          return {} if valid?

          {
            hint: "Name must be capitalized.",
            lines: affected_commit_trailer_lines
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
