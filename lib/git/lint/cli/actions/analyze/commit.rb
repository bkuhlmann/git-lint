# frozen_string_literal: true

require "sod"

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for single commit SHA
          class Commit < Sod::Action
            include Dependencies[:git, :logger, :kernel, :io]

            description "Analyze specific commits."

            on %w[-c --commit], argument: "a,b,c"

            def initialize(analyzer: Analyzer.new, **)
              super(**)
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
                io.puts reporter
                kernel.abort if collector.errors?
              end
            end
          end
        end
      end
    end
  end
end
