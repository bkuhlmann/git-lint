# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit subject uses standard prefix.
      class CommitSubjectPrefix < Abstract
        def valid?
          return true if locally_prefixed?
          return true if filter_list.empty?

          commit.subject.match?(/\A#{Regexp.union filter_list}/)
        end

        def issue
          return {} if valid?

          {hint: %(Use: #{filter_list.to_usage "or"}.)}
        end

        protected

        def load_filter_list
          settings.commits_subject_prefix_includes
                  .map { |prefix| "#{prefix}#{delimiter}" }
                  .then { |list| Kit::FilterList.new list }
        end

        def locally_prefixed? = !ci? && commit.directive?

        def ci? = environment["CI"] == "true"

        def delimiter = settings.commits_subject_prefix_delimiter
      end
    end
  end
end
