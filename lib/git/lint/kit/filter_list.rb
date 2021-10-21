# frozen_string_literal: true

module Git
  module Lint
    module Kit
      # Represents an regular expression list which may be used as an analyzer setting.
      class FilterList
        def initialize list = []
          @list = Array list
        end

        def to_hint = to_regexp.map(&:inspect).join(", ")

        def to_regexp = list.map { |item| Regexp.new item }

        def empty? = list.empty?

        private

        attr_reader :list
      end
    end
  end
end
