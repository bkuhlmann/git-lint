# frozen_string_literal: true

require "refinements/strings"

module Git
  module Lint
    module Validators
      # Validates the format of names.
      class Name
        using Refinements::Strings

        DELIMITER = /\s{1}/
        MINIMUM = 2

        def initialize delimiter: DELIMITER
          @delimiter = delimiter
        end

        def call content, minimum: MINIMUM
          parts = String(content).split delimiter
          parts.size >= minimum && parts.all? { |name| !name.blank? }
        end

        private

        attr_reader :delimiter
      end
    end
  end
end
