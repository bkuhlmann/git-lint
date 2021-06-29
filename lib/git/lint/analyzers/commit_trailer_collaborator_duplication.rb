# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitTrailerCollaboratorDuplication < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error
          }
        end

        def initialize commit:,
                       settings: self.class.defaults,
                       parser: Parsers::Trailers::Collaborator
          super commit: commit, settings: settings
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
