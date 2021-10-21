# frozen_string_literal: true

module Git
  module Lint
    module Parsers
      module Trailers
        # Parses collaborator information within a commit trailer.
        class Collaborator
          DEFAULT_KEY_PATTERN = /\ACo.*Authored.*By.*\Z/i

          DEFAULT_MATCH_PATTERN = /
            (?<key>\A.+)         # Key (anchored to start of line).
            (?<delimiter>:)      # Key delimiter.
            (?<key_space>\s?)    # Space delimiter (optional).
            (?<name>.*?)         # Collaborator name (smallest possible).
            (?<name_space>\s?)   # Space delimiter (optional).
            (?<email><.+>)?      # Collaborator email (optional).
            \Z                   # End of line.
          /x

          def initialize text,
                         key_pattern: DEFAULT_KEY_PATTERN,
                         match_pattern: DEFAULT_MATCH_PATTERN

            @text = String text
            @key_pattern = key_pattern
            @match_pattern = match_pattern
            @matches = build_matches
          end

          def key = String(matches["key"])

          def name = String(matches["name"])

          def email = String(matches["email"]).delete_prefix("<").delete_suffix(">")

          def match? = text.match?(key_pattern)

          private

          attr_reader :text, :key_pattern, :match_pattern, :matches

          def build_matches
            text.match(match_pattern).then { |data| data ? data.named_captures : Hash.new }
          end
        end
      end
    end
  end
end
