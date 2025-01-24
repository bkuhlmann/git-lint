# frozen_string_literal: true

require "core"

module Git
  module Lint
    module Reporters
      # Reports issue for a group of references.
      class Group
        include Dependencies[:color]

        def initialize(analyzer, **)
          super(**)
          @analyzer = analyzer
          @issue = analyzer.issue
        end

        def to_s
          return Core::EMPTY_STRING if issue.empty?

          color[message, style]
        end

        alias to_str to_s

        private

        attr_reader :analyzer, :issue

        def message
          "#{analyzer.class.label}#{severity_suffix}. #{issue.fetch :hint}\n" \
          "#{affected_references}"
        end

        def severity_suffix
          case analyzer.severity
            when "warn" then " Warning"
            when "error" then " Error"
            else ""
          end
        end

        def style
          case analyzer.severity
            when "warn" then :yellow
            when "error" then :red
            else :white
          end
        end

        def affected_references
          issue.fetch(:references, Core::EMPTY_ARRAY)
               .map { |sha| "  #{sha}" }
               .join "\n"
        end
      end
    end
  end
end
