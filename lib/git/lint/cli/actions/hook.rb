# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        # Handles unsaved Git commit action.
        class Hook
          include Git::Lint::Import[:git, :kernel, :logger]

          def initialize(analyzer: Analyzer.new, **)
            super(**)
            @analyzer = analyzer
          end

          def call path
            analyzer.call commits: commits(path) do |collector, reporter|
              kernel.puts reporter
              kernel.abort if collector.errors?
            end
          end

          private

          attr_reader :analyzer

          def commits(path) = git.uncommitted(path).fmap { |commit| [commit] }
        end
      end
    end
  end
end
