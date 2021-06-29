# frozen_string_literal: true

module Git
  module Lint
    module Reporters
      # Reports issues related to a single commit.
      class Commit
        def initialize commit:, analyzers: []
          @commit = commit
          @analyzers = analyzers.select(&:invalid?)
        end

        def to_s
          return "" if analyzers.empty?

          "#{commit.sha} (#{commit.author_name}, #{commit.author_date_relative}): " \
          "#{commit.subject}\n#{report}\n"
        end

        private

        attr_reader :commit, :analyzers

        def report = analyzers.reduce("") { |report, analyzer| report + Style.new(analyzer).to_s }
      end
    end
  end
end
