# frozen_string_literal: true

module Git
  module Lint
    module Reporters
      module Lines
        class Sentence
          def initialize data = {}
            @data = data
          end

          def to_s = %(#{Line::DEFAULT_INDENT}Line #{number}: "#{content}"\n)

          private

          attr_reader :data

          def number = data.fetch(:number)

          def content = data.fetch(:content)
        end
      end
    end
  end
end
