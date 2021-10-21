# frozen_string_literal: true

module Git
  module Lint
    module Validators
      # Validates the format of names.
      class Name
        DEFAULT_DELIMITER = /\s{1}/
        DEFAULT_MINIMUM = 2

        def initialize text, delimiter: DEFAULT_DELIMITER, minimum: DEFAULT_MINIMUM
          @text = text
          @delimiter = delimiter
          @minimum = minimum
        end

        def valid? = parts.size >= minimum && parts.all? { |name| !String(name).empty? }

        private

        attr_reader :text, :delimiter, :minimum

        def parts = String(text).split(delimiter)
      end
    end
  end
end
