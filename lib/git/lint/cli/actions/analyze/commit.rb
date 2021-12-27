# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for commit(s) by SHA.
          class Commit
            def initialize analyzer: Analyzer.new,
                           parser: GitPlus::Parsers::Commits::Saved::History.with_show,
                           container: Container
              @analyzer = analyzer
              @parser = parser
              @container = container
            end

            def call sha = nil
              process sha
            rescue Errors::Base => error
              logger.error { error.message }
              kernel.abort
            end

            private

            attr_reader :analyzer, :parser, :container

            def process sha
              analyzer.call commits: parser.call(*sha) do |collector, reporter|
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
