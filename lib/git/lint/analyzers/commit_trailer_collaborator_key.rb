# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator key usage.
      class CommitTrailerCollaboratorKey < Abstract
        def initialize commit, parser: Parsers::Trailers::Collaborator, **dependencies
          super commit, **dependencies
          @parser = parser
        end

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

        def invalid_line? line
          collaborator = parser.new line
          key = collaborator.key

          collaborator.match? && !key.empty? && !key.match?(
            /\A#{Regexp.union filter_list.to_regexp}\Z/
          )
        end

        private

        attr_reader :parser
      end
    end
  end
end
