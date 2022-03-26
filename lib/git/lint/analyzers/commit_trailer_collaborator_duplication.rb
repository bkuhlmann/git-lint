# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer collaborator duplication.
      class CommitTrailerCollaboratorDuplication < Abstract
        def initialize commit, parser: Parsers::Trailers::Collaborator, **dependencies
          super commit, **dependencies
          @parser = parser
          @tally = build_tally
        end

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Avoid duplication.",
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? line
          collaborator = parser.new line
          collaborator.match? && tally[line] != 1
        end

        private

        attr_reader :parser, :tally

        def build_tally
          zeros = Hash.new { |new_hash, missing_key| new_hash[missing_key] = 0 }

          zeros.tap do |collection|
            commit.trailers.each { |line| collection[line] += 1 if parser.new(line).match? }
          end
        end
      end
    end
  end
end
