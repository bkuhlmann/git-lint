# frozen_string_literal: true

require "core"

module Git
  module Lint
    module Validators
      # Validates content has no repeated words.
      class RepeatedWord
        PATTERN = /
          \w+(?=\s)         # Match word with trailing space.
          |                 # Or.
          (?<=\s)\w+(?=\s)  # Match word between two spaces.
          |                 # Or.
          (?<=\s)\w+        # Match word with leading space.
        /x

        def initialize pattern: PATTERN
          @pattern = pattern
        end

        def call(content) = content ? scan(content) : Core::EMPTY_ARRAY

        private

        attr_reader :pattern

        def scan content
          content.scan(pattern).each_cons(2).with_object [] do |(current, future), repeats|
            repeats.append future if current.casecmp(future).zero?
          end
        end
      end
    end
  end
end
