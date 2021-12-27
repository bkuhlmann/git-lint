# frozen_string_literal: true

require "refinements/structs"

module Git
  module Lint
    module CLI
      module Parsers
        # Handles parsing of Command Line Interface (CLI) core options.
        class Analyze
          using ::Refinements::Structs

          def self.call(...) = new(...).call

          def initialize configuration = Container[:configuration], client: Parser::CLIENT
            @configuration = configuration
            @client = client
          end

          def call arguments = []
            client.separator "\nANALYZE OPTIONS:\n"
            add_sha
            client.parse arguments
            configuration
          end

          private

          attr_reader :configuration, :client

          def add_sha
            client.on "--sha HASH", "Analyze specific commit SHA." do |sha|
              configuration.merge! analyze_sha: sha
            end
          end
        end
      end
    end
  end
end
