# frozen_string_literal: true

module Git
  module Lint
    module Kit
      class FilterList
        # Represents an regular expression list which may be used as an analyzer setting.
        def initialize list = []
          @list = Array list
        end

        def to_hint
          to_regexp.map(&:inspect).join ", "
        end

        def to_regexp
          list.map { |item| Regexp.new item }
        end

        def empty?
          list.empty?
        end

        private

        attr_reader :list
      end
    end
  end
end
