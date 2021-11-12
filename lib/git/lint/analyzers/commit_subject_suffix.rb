# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit subject suffix for punctuation.
      class CommitSubjectSuffix < Abstract
        def valid?
          return true if filter_list.empty?

          !commit.subject.match?(/#{Regexp.union filter_list.to_regexp}\Z/)
        end

        def issue
          return {} if valid?

          {hint: %(Avoid: #{filter_list.to_hint}.)}
        end

        protected

        def load_filter_list = Kit::FilterList.new(settings.excludes)
      end
    end
  end
end
