# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator email address format.
      class CommitTrailerCollaboratorEmail < Abstract
        include Dependencies[
          setting: "trailers.collaborator",
          parser: "parsers.person",
          validator: "validators.email"
        ]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: %(Use format: "<name@server.domain>". Avoid: #{filter_list.to_usage}.),
            lines: affected_commit_trailers
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.commits_trailer_collaborator_email_excludes
        end

        def invalid_line? trailer
          value = trailer.value

          return true if value.match?(/.*#{Regexp.union filter_list}.*/)

          email = parser.call(value).email
          trailer.key.match?(setting.pattern) && !validator.call(email)
        end

        private

        attr_reader :parser, :validator
      end
    end
  end
end
