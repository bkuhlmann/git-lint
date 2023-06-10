# frozen_string_literal: true

require "sod"

module Git
  module Lint
    module CLI
      module Actions
        module Analyze
          # Handles analyze action for branch.
          class Branch < Sod::Action
            include Git::Lint::Import[:kernel, :logger]

            description "Analyze current branch."

            on %w[-b --branch]

            def initialize(analyzer: Analyzer.new, **)
              super(**)
              @analyzer = analyzer
            end

            def call(*)
              parse
            rescue Errors::Base => error
              logger.error { error.message }
              kernel.abort
            end

            private

            attr_reader :analyzer

            def parse
              analyzer.call do |collector, reporter|
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
