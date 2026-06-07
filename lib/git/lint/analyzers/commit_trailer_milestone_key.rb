# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer milestone key usage.
      class CommitTrailerMilestoneKey < Abstract
        include Dependencies[:git, setting: "trailers.milestone"]

        def valid?
          optional? && affected_commit_trailers.empty?
        end

        def issue
          return {} if valid?

          {
            hint: "#{hint_prefix}: #{filter_list.to_usage}.",
            lines: affected_commit_trailers
          }
        end

        protected

        def load_filter_list = Kit::FilterList.new setting.name

        def invalid_line? trailer
          trailer.key.then do |key|
            key.match?(setting.pattern) && !key.match?(/\A#{Regexp.union filter_list}\Z/)
          end
        end

        private

        def optional?
          return true unless mandatory?

          commit.trailers.any? { it.key == setting.name }
        end

        def mandatory? = settings.commits_trailer_milestone_key_mandatory && git.origin?

        def hint_prefix
          settings.commits_trailer_milestone_key_mandatory ? "Use (manditory)" : "Use"
        end
      end
    end
  end
end
