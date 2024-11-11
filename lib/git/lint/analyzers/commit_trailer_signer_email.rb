# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer signer email address format.
      class CommitTrailerSignerEmail < Abstract
        include Dependencies[
          setting: "trailers.signer",
          parser: "parsers.person",
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
          email = parser.call(trailer.value).email
          trailer.key.match?(setting.pattern) && !validator.call(email)
        end

        private

        attr_reader :parser, :validator
      end
    end
  end
end
