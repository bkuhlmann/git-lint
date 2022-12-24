# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator email address format.
      class CommitTrailerCollaboratorEmail < Abstract
        include Import[
          pattern: "trailers.collaborator",
          parser: "parsers.person",
          sanitizer: "sanitizers.email",
          validator: "validators.email"
        ]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: %(Email must follow name and use format: "<name@server.domain>".),
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? trailer
          email = sanitizer.call parser.call(trailer.value).email
          trailer.key.match?(pattern) && !validator.new(email).valid?
        end

        private

        attr_reader :parser, :validator
      end
    end
  end
end
