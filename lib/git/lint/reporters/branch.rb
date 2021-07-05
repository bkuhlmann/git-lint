# frozen_string_literal: true

require "pastel"

module Git
  module Lint
    module Reporters
      # Reports issues related to a single branch.
      class Branch
        using GitPlus::Refinements::Strings

        def initialize collector: Collector.new, colorizer: Pastel.new
          @collector = collector
          @colorizer = colorizer
        end

        def to_s
          "Running #{Identity::LABEL}...#{branch_report}\n" \
          "#{commit_total}. #{issue_totals}.\n"
        end

        private

        attr_reader :collector, :colorizer

        def branch_report
          return "" unless collector.issues?

          "\n\n#{commit_report}".chomp
        end

        def commit_report
          collector.to_h.reduce "" do |details, (commit, analyzers)|
            details + Commit.new(commit: commit, analyzers: analyzers).to_s
          end
        end

        def commit_total
          %(#{"commit".pluralize count: collector.total_commits} inspected)
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
          colorizer.public_send color, "issue".pluralize(count: collector.total_issues)
        end

        def warning_total
          color = collector.warnings? ? :yellow : :green
          colorizer.public_send color, "warning".pluralize(count: collector.total_warnings)
        end

        def error_total
          color = collector.errors? ? :red : :green
          colorizer.public_send color, "error".pluralize(count: collector.total_errors)
        end
      end
    end
  end
end
