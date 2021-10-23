# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for commit(s) by SHA.
          class Commit
            def initialize runner: Runner.new,
                           parser: GitPlus::Parsers::Commits::Saved::History.with_show,
                           container: Container
              @runner = runner
              @parser = parser
              @container = container
            end

            def call shas = []
              process shas
            rescue Errors::Base => error
              logger.error { error.message }
              kernel.abort
            end

            private

            attr_reader :runner, :parser, :container

            def process shas
              runner.call commits: parser.call(*shas) do |collector, reporter|
                kernel.puts reporter
                kernel.abort if collector.errors?
              end
            end

            def kernel = container[__method__]

            def logger = container[__method__]
          end
        end
      end
    end
  end
end
