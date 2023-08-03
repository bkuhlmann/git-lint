# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer signer key usage.
      class CommitTrailerSignerKey < Abstract
        include Import[pattern: "trailers.signer"]

        def valid? = affected_commit_trailers.empty?

        def issue
          return {} if valid?

          {
            hint: "Use format: #{filter_list.to_usage}.",
            lines: affected_commit_trailers
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new configuration.commits_trailer_signer_key_includes
        end

        def invalid_line? trailer
          trailer.key.then do |key|
            key.match?(pattern) && !key.match?(/\A#{Regexp.union filter_list}\Z/)
          end
        end
      end
    end
  end
end
