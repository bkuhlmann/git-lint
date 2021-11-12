# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit body for correct bullet point syntax.
      class CommitBodyBullet < Abstract
        def valid? = commit.body_lines.all? { |line| !invalid_line? line }

        def issue
          return {} if valid?

          {
            hint: %(Avoid: #{filter_list.to_hint}.),
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list = Kit::FilterList.new(settings.excludes)

        # :reek:FeatureEnvy
        def invalid_line? line
          return false if line.strip.empty?

          !line.match?(/\A(?!\s*#{Regexp.union filter_list.to_regexp}\s+).+\Z/)
        end
      end
    end
  end
end
