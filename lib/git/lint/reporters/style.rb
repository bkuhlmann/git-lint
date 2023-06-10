# frozen_string_literal: true

module Git
  module Lint
    module Reporters
      # Reports issues related to a single style.
      class Style
        include Import[:color]

        def initialize(analyzer, **)
          super(**)
          @analyzer = analyzer
          @issue = analyzer.issue
        end

        def to_s = color[message, style]

        alias to_str to_s

        private

        attr_reader :analyzer, :issue

        def message
          "  #{analyzer.class.label}#{severity_suffix}. " \
          "#{issue.fetch :hint}\n" \
          "#{affected_lines}"
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

        def affected_lines
          issue.fetch(:lines, []).reduce("") { |lines, line| lines + Line.new(line) }
        end
      end
    end
  end
end
