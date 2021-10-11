# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        # Handles unsaved Git commit action.
        class Hook
          def initialize runner: Runner.new, container: Container
            @runner = runner
            @container = container
          end

          def call path
            runner.call commits: [repository.unsaved(path)] do |collector, reporter|
              kernel.puts reporter
              kernel.abort if collector.errors?
            end
          end

          private

          attr_reader :runner, :container

          def repository = container[__method__]

          def kernel = container[__method__]

          def logger = container[__method__]
        end
      end
    end
  end
end
