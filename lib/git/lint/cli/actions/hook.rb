# frozen_string_literal: true

require "sod"
require "sod/types/pathname"

module Git
  module Lint
    module CLI
      module Actions
        # Handles unsaved Git commit action.
        class Hook < Sod::Action
          include Dependencies[:git, :logger, :kernel, :io]

          description "Hook for analyzing unsaved commits."

          on "--hook", argument: "PATH", type: Pathname

          def initialize(analyzer: Analyzer.new, **)
            super(**)
            @analyzer = analyzer
          end

          def call path
            reporter = analyzer.call read(path)

            io.puts reporter
            kernel.abort if reporter.errors?
          end

          private

          attr_reader :analyzer

          def read(path) = git.uncommitted(path).bind { |commit| [commit] }
        end
      end
    end
  end
end
