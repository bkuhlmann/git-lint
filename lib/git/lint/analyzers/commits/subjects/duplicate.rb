# frozen_string_literal: true

require "refinements/array"

module Git
  module Lint
    module Analyzers
      module Commits
        module Subjects
          # Analyzes and detects duplicate subjects.
          class Duplicate < Abstract
            using Refinements::Array

            def self.id = "commits_subject_duplicate"

            def self.label = "Commit Subject Duplicate"

            def initialize(commits, **)
              super(nil, **)
              @commits = commits
            end

            def valid? = normals.map(&:subject).tally.all? { |_subject, total| total == 1 }

            def issue
              return {} if valid?

              {
                hint: "Use unique subjects.",
                references: normals.map { |commit| "#{commit.sha} #{commit.subject}" }
              }
            end

            private

            attr_reader :commits

            def normals = commits.reject(&:directive?)
          end
        end
      end
    end
  end
end
