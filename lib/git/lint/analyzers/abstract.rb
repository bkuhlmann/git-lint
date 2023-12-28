# frozen_string_literal: true

require "core"
require "refinements/string"

module Git
  module Lint
    module Analyzers
      # An abstract class which provides basic functionality for all analyzers to inherit from.
      class Abstract
        include Import[:configuration, :environment]

        using Refinements::String

        LEVELS = %w[warn error].freeze
        BODY_OFFSET = 3

        def self.id = to_s.delete_prefix!("Git::Lint::Analyzers").snakecase

        def self.label = to_s.delete_prefix("Git::Lint::Analyzers").titleize

        def self.build_issue_line(index, line) = {number: index + BODY_OFFSET, content: line}

        attr_reader :commit

        def initialize(commit, **)
          super(**)
          @commit = commit
          @filter_list = load_filter_list
        end

        def severity
          configuration.public_send("#{self.class.id}_severity".sub("commit_", "commits_"))
                       .tap { |level| fail Errors::Severity, level unless LEVELS.include? level }
        end

        def valid?
          fail NotImplementedError, "The `##{__method__}` method must be implemented."
        end

        def invalid? = !valid?

        def warning? = invalid? && severity == "warn"

        def error? = invalid? && severity == "error"

        def issue
          fail NotImplementedError, "The `##{__method__}` method must be implemented."
        end

        protected

        attr_reader :filter_list

        def load_filter_list = Core::EMPTY_ARRAY

        def affected_commit_body_lines
          commit.body_lines.each.with_object([]).with_index do |(line, lines), index|
            lines << self.class.build_issue_line(index, line) if invalid_line? line
          end
        end

        def affected_commit_trailers
          commit.trailers
                .each
                .with_object([])
                .with_index(commit.body_lines.size) do |(trailer, trailers), index|
                  next unless invalid_line? trailer

                  trailers << self.class.build_issue_line(index, trailer.to_s)
                end
        end

        def invalid_line? _line
          fail NotImplementedError, "The `.#{__method__}` method must be implemented."
        end
      end
    end
  end
end
