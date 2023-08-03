# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      # Analyzes commit trailer order value.
      class CommitTrailerOrder < Abstract
        def initialize(...)
          super
          @original_order = commit.trailers.map(&:key)
          @sorted_order = original_order.sort
        end

        def valid? = original_order == sorted_order

        def issue
          return {} if valid?

          {
            hint: "Ensure keys are alphabetically sorted.",
            lines: affected_commit_trailers
          }
        end

        protected

        def invalid_line? trailer
          key = trailer.key
          original_order.index(key) != sorted_order.index(key)
        end

        private

        attr_reader :original_order, :sorted_order
      end
    end
  end
end
