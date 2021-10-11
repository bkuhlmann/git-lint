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

      def initialize configuration = Container[:configuration].analyzers,
                     analyzers: ANALYZERS,
                     collector: Collector.new
        @configuration = configuration
        @analyzers = analyzers
        @collector = collector
      end

      def call commits: Commits::Loader.new.call
        commits.map { |commit| check commit }
        collector
      end

      private

      attr_reader :configuration, :analyzers, :collector

      def check commit
        configuration.map { |id, settings| load_analyzer id, commit, settings }
                     .select(&:enabled?)
                     .map { |analyzer| collector.add analyzer }
      end

      def load_analyzer id, commit, settings
        analyzers.find { |analyzer| analyzer.id == id }
                 .then do |analyzer|
                   fail Errors::Base, "Invalid analyzer detected: #{id}." unless analyzer

                   analyzer.new commit: commit, settings: settings
                 end
      end
    end
  end
end
