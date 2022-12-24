# frozen_string_literal: true

module Git
  module Lint
    module Validators
      # Validates the capitalizationn of text.
      class Capitalization
        PATTERN = /\A[[:upper:]].*\Z/

        def initialize delimiter: Name::DELIMITER, pattern: PATTERN
          @delimiter = delimiter
          @pattern = pattern
        end

        def call(content) = String(content).split(delimiter).all? { |name| name.match? pattern }

        private

        attr_reader :delimiter, :pattern
      end
    end
  end
end
