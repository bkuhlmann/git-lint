# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator key usage.
      class CommitTrailerCollaboratorKey < Abstract
        include Import[pattern: "trailers.collaborator"]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Use format: #{filter_list.to_hint}.",
            lines: affected_commit_trailers
          }
        end

        protected

        def load_filter_list = Kit::FilterList.new(settings.includes)

        def invalid_line? trailer
          trailer.key.then do |key|
            key.match?(pattern) && !key.match?(/\A#{Regexp.union filter_list.to_regexp}\Z/)
          end
        end
      end
    end
  end
end
