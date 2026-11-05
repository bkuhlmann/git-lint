# frozen_string_literal: true

require "core"

module Git
  module Lint
    # Runs all analyzers.
    class Analyzer
      DELEGATES = [Analyzers::Commits::Sole, Analyzers::Commits::Many].freeze

      include Dependencies[:collector]

      def initialize(reporter: Reporters::Branch, delegates: DELEGATES, **)
        super(**)
        @reporter = reporter
        @delegates = delegates
      end

      def call commits = Core::EMPTY_ARRAY
        process commits
        reporter.new total: collector.total
      end

      private

      attr_reader :reporter, :delegates

      def process commits
        collector.clear
        delegates.each { |delegate| delegate.new.call commits }
      end
    end
  end
end
