# frozen_string_literal: true

module Git
  module Lint
    # Runs all analyzers.
    class Runner
      ANALYZERS = [
        Analyzers::CommitAuthorCapitalization,
        Analyzers::CommitAuthorEmail,
        Analyzers::CommitAuthorName,
        Analyzers::CommitBodyBullet,
        Analyzers::CommitBodyBulletCapitalization,
        Analyzers::CommitBodyBulletDelimiter,
        Analyzers::CommitBodyIssueTrackerLink,
        Analyzers::CommitBodyLeadingLine,
        Analyzers::CommitBodyLineLength,
        Analyzers::CommitBodyParagraphCapitalization,
        Analyzers::CommitBodyPhrase,
        Analyzers::CommitBodyPresence,
        Analyzers::CommitBodySingleBullet,
        Analyzers::CommitSubjectLength,
        Analyzers::CommitSubjectPrefix,
        Analyzers::CommitSubjectSuffix,
        Analyzers::CommitTrailerCollaboratorCapitalization,
        Analyzers::CommitTrailerCollaboratorDuplication,
        Analyzers::CommitTrailerCollaboratorEmail,
        Analyzers::CommitTrailerCollaboratorKey,
        Analyzers::CommitTrailerCollaboratorName
      ].freeze

      # rubocop:disable Metrics/ParameterLists
      def initialize analyzers: ANALYZERS,
                     collector: Collector.new,
                     reporter: Reporters::Branch,
                     container: Container
        @analyzers = analyzers
        @collector = collector
        @reporter = reporter
        @container = container
      end
      # rubocop:enable Metrics/ParameterLists

      def call commits: Commits::Loader.new.call
        process commits
        a_reporter = reporter.new collector: collector
        block_given? ? yield(collector, a_reporter) : [collector, a_reporter]
      end

      private

      attr_reader :analyzers, :collector, :reporter, :container

      def process commits
        collector.clear
        commits.map { |commit| analyze commit }
      end

      def analyze commit
        settings.map { |setting| load_analyzer commit, setting.id }
                .select(&:enabled?)
                .map { |analyzer| collector.add analyzer }
      end

      def load_analyzer commit, id
        analyzers.find { |analyzer| analyzer.id == id }
                 .then do |analyzer|
                   fail Errors::Base, "Invalid analyzer detected: #{id}." unless analyzer

                   analyzer.new commit
                 end
      end

      def settings = container[:configuration].analyzers
    end
  end
end
