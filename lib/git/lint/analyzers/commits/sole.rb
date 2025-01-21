# frozen_string_literal: true

require "core"

module Git
  module Lint
    module Analyzers
      module Commits
        # Runs all analyzers for a single commit only.
        class Sole
          include Dependencies[:settings, :collector]

          ANALYZERS = [
            Analyzers::CommitAuthorCapitalization,
            Analyzers::CommitAuthorEmail,
            Analyzers::CommitAuthorName,
            Analyzers::CommitBodyBulletCapitalization,
            Analyzers::CommitBodyBulletDelimiter,
            Analyzers::CommitBodyBulletOnly,
            Analyzers::CommitBodyLeadingLine,
            Analyzers::CommitBodyLineLength,
            Analyzers::CommitBodyParagraphCapitalization,
            Analyzers::CommitBodyPhrase,
            Analyzers::CommitBodyPresence,
            Analyzers::CommitBodyTrackerShorthand,
            Analyzers::CommitBodyWordRepeat,
            Analyzers::CommitSignature,
            Analyzers::CommitSubjectLength,
            Analyzers::CommitSubjectPrefix,
            Analyzers::CommitSubjectSuffix,
            Analyzers::CommitSubjectWordRepeat,
            Analyzers::CommitTrailerCollaboratorCapitalization,
            Analyzers::CommitTrailerCollaboratorEmail,
            Analyzers::CommitTrailerCollaboratorKey,
            Analyzers::CommitTrailerCollaboratorName,
            Analyzers::CommitTrailerDuplicate,
            Analyzers::CommitTrailerFormatKey,
            Analyzers::CommitTrailerFormatValue,
            Analyzers::CommitTrailerIssueKey,
            Analyzers::CommitTrailerIssueValue,
            Analyzers::CommitTrailerMilestoneKey,
            Analyzers::CommitTrailerMilestoneValue,
            Analyzers::CommitTrailerOrder,
            Analyzers::CommitTrailerReviewerKey,
            Analyzers::CommitTrailerReviewerValue,
            Analyzers::CommitTrailerSignerCapitalization,
            Analyzers::CommitTrailerSignerEmail,
            Analyzers::CommitTrailerSignerKey,
            Analyzers::CommitTrailerSignerName,
            Analyzers::CommitTrailerTrackerKey,
            Analyzers::CommitTrailerTrackerValue
          ].freeze

          def initialize(analyzers: ANALYZERS, **)
            super(**)
            @analyzers = analyzers
          end

          def call commits = Core::EMPTY_ARRAY
            commits.each { |commit| select commit }
            collector
          end

          private

          attr_reader :analyzers

          def select commit
            settings.to_h
                    .select { |key, value| key.end_with?("enabled") && value == true }
                    .each_key do |key|
                      id = key.to_s.sub("commits_", "commit_").delete_suffix! "_enabled"
                      add commit, id
                    end
          end

          def add commit, id
            analyzers.find { |analyzer| analyzer.id == id }
                     .then { |analyzer| collector.add analyzer.new(commit) if analyzer }
          end
        end
      end
    end
  end
end
