# frozen_string_literal: true

require "sod"

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for branch.
          class Branch < Sod::Action
            include Dependencies[:logger, :kernel, :io]

            description "Analyze current branch."

            on %w[-b --branch]

            def initialize(analyzer: Analyzer.new, loader: Git::Lint::Commits::Loader.new, **)
              super(**)
              @analyzer = analyzer
              @loader = loader
            end

            def call(*)
              report
            rescue Errors::Base => error
              logger.abort error.message
            end

            private

            attr_reader :analyzer, :loader

            def report
              loader.call.bind do |commits|
                reporter = analyzer.call commits
                io.puts reporter
                kernel.abort if reporter.errors?
              end
            end
          end
        end
      end
    end
  end
end
