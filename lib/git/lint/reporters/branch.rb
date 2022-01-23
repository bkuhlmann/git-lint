# frozen_string_literal: true

require "pastel"

module Git
  module Lint
    module Reporters
      # Reports issues related to a single branch.
      class Branch
        using ::Refinements::Strings

        def initialize collector: Collector.new, colorizer: Pastel.new
          @collector = collector
          @colorizer = colorizer
        end

        def to_s
          "Running Git Lint...#{branch_report}\n" \
          "#{commit_total}. #{issue_totals}.\n"
        end

        alias to_str to_s

        private

        attr_reader :collector, :colorizer

        def branch_report
          return "" unless collector.issues?

          "\n\n#{commit_report}".chomp
        end

        def commit_report
          collector.to_h.reduce "" do |details, (commit, analyzers)|
            details + Commit.new(commit:, analyzers:)
          end
        end

        def commit_total
          total = collector.total_commits
          %(#{total} #{"commit".pluralize "s", count: total} inspected)
        end

        def issue_totals
          if collector.issues?
            "#{issue_total} detected (#{warning_total}, #{error_total})"
          else
            colorizer.green("0 issues") + " detected"
          end
        end

        def issue_total
          color = collector.errors? ? :red : :yellow
          total = collector.total_issues
          colorizer.public_send color, "#{total} issue".pluralize("s", count: total)
        end

        def warning_total
          color = collector.warnings? ? :yellow : :green
          total = collector.total_warnings
          colorizer.public_send color, "#{total} warning".pluralize("s", count: total)
        end

        def error_total
          color = collector.errors? ? :red : :green
          total = collector.total_errors
          colorizer.public_send color, "#{total} error".pluralize("s", count: total)
        end
      end
    end
  end
end
