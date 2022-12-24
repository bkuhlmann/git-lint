# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for single commit SHA
          class Commit
            include Git::Lint::Import[:git, :kernel, :logger]

            def initialize analyzer: Analyzer.new, **dependencies
              super(**dependencies)
              @analyzer = analyzer
            end

            def call *arguments
              process arguments.unshift "-1"
            rescue Errors::Base => error
              logger.error { error.message }
              kernel.abort
            end

            private

            attr_reader :analyzer

            def process arguments
              analyzer.call commits: git.commits(*arguments) do |collector, reporter|
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
