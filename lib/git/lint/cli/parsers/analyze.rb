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
            add_shas
            client.parse arguments
            configuration
          end

          private

          attr_reader :configuration, :client

          def add_shas
            client.on "--shas a,b,c", Array, "Analyze specific commit SHAs." do |shas|
              configuration.merge! analyze_shas: shas
            end
          end
        end
      end
    end
  end
end
