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
              collect arguments.unshift("-1")
            rescue Errors::Base => error
              logger.abort error.message
            end

            private

            attr_reader :analyzer

            def collect arguments
              git.commits(*arguments).either -> commits { report commits },
                                             -> message { logger.abort message.chomp }
            end

            def report commits
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
