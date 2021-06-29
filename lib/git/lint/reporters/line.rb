# frozen_string_literal: true

module Git
  module Lint
    module Reporters
      # Reports issues related to an invalid line within the commit body.
      class Line
        DEFAULT_INDENT = "    "

        def initialize data = {}
          @data = data
        end

        def to_s
          if content.include? "\n"
            Lines::Paragraph.new(data).to_s
          else
            Lines::Sentence.new(data).to_s
          end
        end

        private

        attr_reader :data

        def content = data.fetch(__method__)
      end
    end
  end
end
