# frozen_string_literal: true

module Git
  module Lint
    module Reporters
      module Lines
        # Reports paragraph details.
        class Paragraph
          def initialize data = {}
            @data = data
          end

          def to_s
            %(#{label}"#{paragraph}"\n)
          end

          alias to_str to_s

          private

          attr_reader :data

          def label = "#{Line::DEFAULT_INDENT}Line #{number}: "

          def paragraph = formatted_lines.join("\n")

          def formatted_lines
            content.split("\n").map.with_index do |line, index|
              index.zero? ? line : "#{indent}#{line}"
            end
          end

          def indent = " " * (label.length + 1)

          def number = data.fetch(:number)

          def content = data.fetch(:content)
        end
      end
    end
  end
end
