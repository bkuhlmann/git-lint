# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitSubjectSuffix < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            excludes: [
              "\\.",
              "\\?",
              "\\!"
            ]
          }
        end

        def valid?
          return true if filter_list.empty?

          !commit.subject.match?(/#{Regexp.union filter_list.to_regexp}\Z/)
        end

        def issue
          return {} if valid?

          {hint: %(Avoid: #{filter_list.to_hint}.)}
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.fetch(:excludes)
        end
      end
    end
  end
end
