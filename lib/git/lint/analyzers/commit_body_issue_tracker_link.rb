# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitBodyIssueTrackerLink < Abstract
        def self.defaults
          {
            enabled: true,
            severity: :error,
            excludes: [
              "(f|F)ix(es|ed)?\\s\\#\\d+",
              "(c|C)lose(s|d)?\\s\\#\\d+",
              "(r|R)esolve(s|d)?\\s\\#\\d+",
              "github\\.com\\/.+\\/issues\\/\\d+"
            ]
          }
        end

        def valid?
          commit.body_lines.none? { |line| invalid_line? line }
        end

        def issue
          return {} if valid?

          {
            hint: "Explain issue instead of using link. Avoid: #{filter_list.to_hint}.",
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.fetch :excludes
        end

        def invalid_line? line
          line.match?(/.*#{Regexp.union filter_list.to_regexp}.*/)
        end
      end
    end
  end
end
