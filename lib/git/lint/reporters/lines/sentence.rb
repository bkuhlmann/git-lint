# frozen_string_literal: true

module Git
  module Lint
    module Reporters
      module Lines
        # Reports sentence details.
        class Sentence
          def initialize data = {}
            @data = data
          end

          def to_s = %(#{Line::DEFAULT_INDENT}Line #{number}: "#{content}"\n)

          alias to_str to_s

          private

          attr_reader :data

          def number = data.fetch(:number)

          def content = data.fetch(:content)
        end
      end
    end
  end
end
