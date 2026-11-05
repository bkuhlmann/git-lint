# frozen_string_literal: true

require "core"

module Git
  module Lint
    module Analyzers
      module Commits
        # Runs all analyzers for a single commit only.
        class Many
          ANALYZERS = [Analyzers::Commits::Subjects::Duplicate].freeze

          include Dependencies[:settings, :collector]

          def initialize(analyzers: ANALYZERS, **)
            super(**)
            @analyzers = analyzers
          end

          def call commits = Core::EMPTY_ARRAY
            analyzers.select { |analyzer| settings.public_send :"#{analyzer.id}_enabled" }
                     .each { |analyzer| collector.add analyzer.new(commits) }

            collector
          end

          private

          attr_reader :analyzers
        end
      end
    end
  end
end
