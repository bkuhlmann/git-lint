# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for branch.
          class Branch
            def initialize runner: Runner.new, container: Container
              @runner = runner
              @container = container
            end

            def call
              parse
            rescue Errors::Base => error
              logger.error { error.message }
              kernel.abort
            end

            private

            attr_reader :runner, :container

            def parse
              runner.call do |collector, reporter|
                kernel.puts reporter
                kernel.abort if collector.errors?
              end
            end

            def repository = container[__method__]

            def kernel = container[__method__]

            def logger = container[__method__]
          end
        end
      end
    end
  end
end
