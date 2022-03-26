# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for commit(s) by SHA.
          class Commit
            include Git::Lint::Import[:kernel, :logger]

            def initialize analyzer: Analyzer.new,
                           parser: GitPlus::Parsers::Commits::Saved::History.with_show,
                           **dependencies
              super(**dependencies)
              @analyzer = analyzer
              @parser = parser
            end

            def call sha = nil
              process sha
            rescue Errors::Base => error
              logger.error { error.message }
              kernel.abort
            end

            private

            attr_reader :analyzer, :parser

            def process sha
              analyzer.call commits: parser.call(*sha) do |collector, reporter|
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
