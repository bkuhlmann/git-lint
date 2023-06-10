# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit signature validity.
      class CommitSignature < Abstract
        include Import[sanitizer: "sanitizers.signature"]

        def valid?
          sanitizer.call(commit.signature).match?(/\A#{Regexp.union filter_list.to_regexp}\Z/)
        end

        def issue = valid? ? {} : {hint: %(Use: #{filter_list.to_hint}.)}

        protected

        def load_filter_list
          Kit::FilterList.new configuration.commits_signature_includes
        end
      end
    end
  end
end
