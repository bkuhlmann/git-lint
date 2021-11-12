# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit subject uses standard prefix.
      class CommitSubjectPrefix < Abstract
        def valid?
          return true if commit.prefix?
          return true if filter_list.empty?

          commit.subject.match?(/\A#{Regexp.union filter_list.to_regexp}/)
        end

        def issue
          return {} if valid?

          {hint: %(Use: #{filter_list.to_hint}.)}
        end

        protected

        def load_filter_list = Kit::FilterList.new(settings.includes)
      end
    end
  end
end
