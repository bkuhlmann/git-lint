# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit subject uses standard prefix.
      class CommitSubjectPrefix < Abstract
        def valid?
          return true if locally_prefixed?
          return true if filter_list.empty?

          commit.subject.match?(/\A#{Regexp.union filter_list.to_regexp}/)
        end

        def issue
          return {} if valid?

          {hint: %(Use: #{filter_list.to_hint}.)}
        end

        protected

        def load_filter_list
          settings.includes
                  .map { |prefix| "#{prefix}#{settings.delimiter}" }
                  .then { |list| Kit::FilterList.new list }
        end

        def locally_prefixed? = !ci? && commit.prefix?

        def ci? = environment["CI"] == "true"
      end
    end
  end
end
