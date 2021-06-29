# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitTrailerCollaboratorKey < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            includes: ["Co-Authored-By"]
          }
        end

        def initialize commit:,
                       settings: self.class.defaults,
                       parser: Parsers::Trailers::Collaborator
          super commit: commit, settings: settings
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

        def load_filter_list = Kit::FilterList.new(settings.fetch(:includes))

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
