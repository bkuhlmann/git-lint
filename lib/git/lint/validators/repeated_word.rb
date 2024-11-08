# frozen_string_literal: true

require "core"

module Git
  module Lint
    module Validators
      # Validates content has no repeated words.
      class RepeatedWord
        PATTERNS = {
          word: /
            \w+(?=\s)         # Match word with trailing space.
            |                 # Or.
            (?<=\s)\w+(?=\s)  # Match word between two spaces.
            |                 # Or.
            (?<=\s)\w+        # Match word with leading space.
          /x,
          code_block: /`.+`/,
          version: /\d+\./
        }.freeze

        def initialize patterns: PATTERNS
          @patterns = patterns
        end

        def call(content) = content ? scan(content) : Core::EMPTY_ARRAY

        private

        attr_reader :patterns

        def scan content
          parse(content).each_cons(2).with_object [] do |(current, future), repeats|
            repeats.append future if current.casecmp(future).zero?
          end
        end

        def parse content
          content.gsub(code_block_pattern, "").gsub(version_pattern, "").scan word_pattern
        end

        def word_pattern = patterns.fetch :word

        def code_block_pattern = patterns.fetch :code_block

        def version_pattern = patterns.fetch :version
      end
    end
  end
end
