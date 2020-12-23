# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitSubjectPrefix < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            includes: %w[Fixed Added Updated Removed Refactored]
          }
        end

        def valid?
          return true if fixup_or_squash?
          return true if filter_list.empty?

          commit.subject.match?(/\A#{Regexp.union filter_list.to_regexp}/)
        end

        def issue
          return {} if valid?

          {hint: %(Use: #{filter_list.to_hint}.)}
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.fetch(:includes)
        end

        private

        def fixup_or_squash?
          commit.fixup? || commit.squash?
        end
      end
    end
  end
end
