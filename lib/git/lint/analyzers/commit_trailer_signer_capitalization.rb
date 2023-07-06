# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer signer name capitalization.
      class CommitTrailerSignerCapitalization < Abstract
        include Import[
          setting: "trailers.signer",
          parser: "parsers.person",
          validator: "validators.capitalization"
        ]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Name must be capitalized.",
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? trailer
          parser.call(trailer.value).then do |person|
            trailer.key.match?(setting.pattern) && !validator.call(person.name)
          end
        end
      end
    end
  end
end
