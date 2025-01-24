# frozen_string_literal: true

require "forwardable"

module Git
  module Lint
    module Reporters
      # Reports issues related to a single branch.
      class Branch
        extend Forwardable

        include Dependencies[:collector, :color]

        using Refinements::String

        DELEGATES = {individual: Individual, group: Group}.freeze

        delegate %i[empty? issues? warnings? errors?] => :total

        def initialize(total: Models::Total.new, delegates: DELEGATES, **)
          super(**)
          @total = total
          @delegates = delegates
        end

        def to_s
          "Running Git Lint...#{branch_report}\n" \
          "#{commit_total}. #{issue_totals}.\n"
        end

        alias to_str to_s

        private

        attr_reader :total, :delegates

        def branch_report
          return "" unless total.issues?

          "\n\n#{commit_report}".chomp
        end

        def commit_report
          collector.to_h.reduce "" do |details, (reference, analyzers)|
            if reference
              details + individual.new(reference, analyzers:)
            else
              details + group_by(analyzers)
            end
          end
        end

        def group_by analyzers
          analyzers.reduce(+"") { |text, analyzer| text << group.new(analyzer) }
        end

        def commit_total
          commits = total.items
          %(#{commits} #{"commit".pluralize "s", commits} inspected)
        end

        def issue_totals
          if total.issues?
            "#{issue_total} detected (#{warning_total}, #{error_total})"
          else
            color["0 issues", :green] + " detected"
          end
        end

        def issue_total
          style = total.errors? ? :red : :yellow
          issues = total.issues
          color["#{issues} issue".pluralize("s", issues), style]
        end

        def warning_total
          style = total.warnings? ? :yellow : :green
          warnings = total.warnings
          color["#{warnings} warning".pluralize("s", warnings), style]
        end

        def error_total
          style = total.errors? ? :red : :green
          errors = total.errors
          color["#{errors} error".pluralize("s", errors), style]
        end

        def individual = delegates.fetch __method__

        def group = delegates.fetch __method__
      end
    end
  end
end
