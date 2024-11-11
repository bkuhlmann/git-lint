# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit signature validity.
      class CommitSignature < Abstract
        include Dependencies[sanitizer: "sanitizers.signature"]

        def valid?
          sanitizer.call(commit.signature).match?(/\A#{Regexp.union filter_list}\Z/)
        end

        def issue = valid? ? {} : {hint: %(Use: #{filter_list.to_usage "or"}.)}

        protected

        def load_filter_list
          Kit::FilterList.new settings.commits_signature_includes
        end
      end
    end
  end
end
