# frozen_string_literal: true

module Git
  module Lint
    # Runs all analyzers.
    class Runner
      def initialize configuration:, collector: Collector.new
        @configuration = configuration
        @collector = collector
      end

      def call commits: Commits::Loader.new.call
        commits.map { |commit| check commit }
        collector
      end

      private

      attr_reader :configuration, :branch, :collector

      def check commit
        configuration.map { |id, settings| load_analyzer id, commit, settings }
                     .select(&:enabled?)
                     .map { |analyzer| collector.add analyzer }
      end

      def load_analyzer id, commit, settings
        klass = Analyzers::Abstract.descendants.find { |descendant| descendant.id == id }
        fail Errors::Base, "Invalid analyzer: #{id}. See docs for supported analyzer." unless klass

        klass.new commit: commit, settings: settings
      end
    end
  end
end
