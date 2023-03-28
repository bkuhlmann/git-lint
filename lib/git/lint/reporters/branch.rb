# frozen_string_literal: true

module Git
  module Lint
    module Reporters
      # Reports issues related to a single branch.
      class Branch
        include Import[:color]
        using ::Refinements::Strings

        def initialize(collector: Collector.new, **)
          super(**)
          @collector = collector
        end

        def to_s
          "Running Git Lint...#{branch_report}\n" \
          "#{commit_total}. #{issue_totals}.\n"
        end

        alias to_str to_s

        private

        attr_reader :collector

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
            color["0 issues", :green] + " detected"
          end
        end

        def issue_total
          style = collector.errors? ? :red : :yellow
          total = collector.total_issues
          color["#{total} issue".pluralize("s", count: total), style]
        end

        def warning_total
          style = collector.warnings? ? :yellow : :green
          total = collector.total_warnings
          color["#{total} warning".pluralize("s", count: total), style]
        end

        def error_total
          style = collector.errors? ? :red : :green
          total = collector.total_errors
          color["#{total} error".pluralize("s", count: total), style]
        end
      end
    end
  end
end
