# frozen_string_literal: true

require "core"
require "refinements/array"

module Git
  module Lint
    module Kit
      # Represents an regular expression list which may be used as an analyzer setting.
      class FilterList
        using Refinements::Array

        def initialize list = Core::EMPTY_ARRAY
          @list = Array(list).map { |item| Regexp.new item }
        end

        def empty? = list.empty?

        def to_a = list

        alias to_ary to_a

        def to_usage(...) = list.to_usage(...)

        private

        attr_reader :list
      end
    end
  end
end
