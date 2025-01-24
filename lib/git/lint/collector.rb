# frozen_string_literal: true

module Git
  module Lint
    # Collects and categorizes, by severity, all issues (if any).
    class Collector
      def initialize model: Models::Total
        @model = model
        @collection = Hash.new { |default, missing_id| default[missing_id] = [] }
      end

      def add analyzer
        collection[analyzer.commit] << analyzer
        analyzer
      end

      def total
        values = collection.values.flatten

        model[
          items: collection.keys.compact.size,
          issues: values.count(&:invalid?),
          warnings: values.count(&:warning?),
          errors: values.count(&:error?)
        ]
      end

      def retrieve(id) = collection[id]

      def clear = collection.clear && self

      def empty? = collection.empty?

      def warnings? = collection.values.flatten.any?(&:warning?)

      def errors? = collection.values.flatten.any?(&:error?)

      def issues? = collection.values.flatten.any?(&:invalid?)

      def total_warnings = collection.values.flatten.count(&:warning?)

      def total_errors = collection.values.flatten.count(&:error?)

      def total_issues = collection.values.flatten.count(&:invalid?)

      def total_commits = collection.keys.size

      def to_h = collection

      private

      attr_reader :model, :collection
    end
  end
end
