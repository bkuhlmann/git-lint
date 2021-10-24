# frozen_string_literal: true

require "pastel"

module Git
  module Lint
    module Reporters
      # Reports issues related to a single style.
      class Style
        def initialize analyzer, colorizer: Pastel.new
          @analyzer = analyzer
          @issue = analyzer.issue
          @colorizer = colorizer
        end

        def to_s = colorizer.public_send(color, message)

        alias to_str to_s

        private

        attr_reader :analyzer, :issue, :colorizer

        def message
          "  #{analyzer.class.label}#{severity_suffix}. " \
          "#{issue.fetch :hint}\n" \
          "#{affected_lines}"
        end

        def severity_suffix
          case analyzer.severity
            when :warn then " Warning"
            when :error then " Error"
            else ""
          end
        end

        def color
          case analyzer.severity
            when :warn then :yellow
            when :error then :red
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
