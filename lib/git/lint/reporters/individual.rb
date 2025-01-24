# frozen_string_literal: true

module Git
  module Lint
    module Reporters
      # Reports issues related to a single reference.
      class Individual
        def initialize reference, analyzers: []
          @reference = reference
          @analyzers = analyzers.select(&:invalid?)
        end

        def to_s
          return "" if analyzers.empty?

          "#{reference.sha} (#{reference.author_name}, #{reference.authored_relative_at}): " \
          "#{reference.subject}\n#{report}\n"
        end

        alias to_str to_s

        private

        attr_reader :reference, :analyzers

        def report = analyzers.reduce("") { |report, analyzer| report + Style.new(analyzer) }
      end
    end
  end
end
