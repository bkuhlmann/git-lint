# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        # Handles unsaved Git commit action.
        class Hook
          include Git::Lint::Import[:repository, :kernel, :logger]

          def initialize analyzer: Analyzer.new, **dependencies
            super(**dependencies)
            @analyzer = analyzer
          end

          def call path
            analyzer.call commits: [repository.unsaved(path)] do |collector, reporter|
              kernel.puts reporter
              kernel.abort if collector.errors?
            end
          end

          private

          attr_reader :analyzer
        end
      end
    end
  end
end
