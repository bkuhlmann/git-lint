# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit subject suffix for punctuation.
      class CommitSubjectSuffix < Abstract
        def valid?
          return true if filter_list.empty?

          !commit.subject.match?(/#{Regexp.union filter_list}\Z/)
        end

        def issue
          return {} if valid?

          {hint: %(Avoid: #{filter_list.to_usage}.)}
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.commits_subject_suffix_excludes
        end
      end
    end
  end
end
