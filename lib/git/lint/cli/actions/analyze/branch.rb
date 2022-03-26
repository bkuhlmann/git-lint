# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for branch.
          class Branch
            include Git::Lint::Import[:repository, :kernel, :logger]

            def initialize analyzer: Analyzer.new, **dependencies
              super(**dependencies)
              @analyzer = analyzer
            end

            def call
              parse
            rescue Errors::Base => error
              logger.error { error.message }
              kernel.abort
            end

            private

            attr_reader :analyzer

            def parse
              analyzer.call do |collector, reporter|
                kernel.puts reporter
                kernel.abort if collector.errors?
              end
            end
          end
        end
      end
    end
  end
end
