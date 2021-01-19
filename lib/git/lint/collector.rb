# frozen_string_literal: true

require "refinements/hashes"

module Git
  module Lint
    class Collector
      using ::Refinements::Hashes

      def initialize
        @collection = Hash.new { |default, missing_id| default[missing_id] = [] }
      end

      def add analyzer
        collection[analyzer.commit] << analyzer
        analyzer
      end

      def retrieve id
        collection[id]
      end

      def empty?
        collection.empty?
      end

      def warnings?
        collection.values.flatten.any?(&:warning?)
      end

      def errors?
        collection.values.flatten.any?(&:error?)
      end

      def issues?
        collection.values.flatten.any?(&:invalid?)
      end

      def total_warnings
        collection.values.flatten.count(&:warning?)
      end

      def total_errors
        collection.values.flatten.count(&:error?)
      end

      def total_issues
        collection.values.flatten.count(&:invalid?)
      end

      def total_commits
        collection.keys.size
      end

      def to_h
        collection
      end

      private

      attr_reader :collection
    end
  end
end
