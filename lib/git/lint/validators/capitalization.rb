# frozen_string_literal: true

module Git
  module Lint
    module Validators
      class Capitalization
        DEFAULT_PATTERN = /\A[[:upper:]].*\Z/

        def initialize text, delimiter: Name::DEFAULT_DELIMITER, pattern: DEFAULT_PATTERN
          @text = String text
          @delimiter = delimiter
          @pattern = pattern
        end

        def valid?
          parts.all? { |name| String(name).match? pattern }
        end

        private

        attr_reader :text, :delimiter, :pattern

        def parts
          text.split delimiter
        end
      end
    end
  end
end
