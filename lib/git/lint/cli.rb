# frozen_string_literal: true

require "thor"
require "thor/actions"
require "runcom"
require "pathname"
require "pastel"

module Git
  module Lint
    # The Command Line Interface (CLI) for the gem.
    class CLI < Thor
      include Thor::Actions

      package_name Identity::VERSION_LABEL

      def self.configuration
        defaults = Analyzers::Abstract.descendants.reduce({}) do |settings, analyzer|
          settings.merge analyzer.id => analyzer.defaults
        end

        Runcom::Config.new "#{Identity::NAME}/configuration.yml", defaults: defaults
      end

      def initialize args = [], options = {}, config = {}
        super args, options, config
        @configuration = self.class.configuration
        @runner = Runner.new configuration: @configuration.to_h
        @colorizer = Pastel.new
      rescue Runcom::Errors::Base => error
        abort error.message
      end

      desc "-c, [--config]", "Manage gem configuration."
      map %w[-c --config] => :config
      method_option :edit,
                    aliases: "-e",
                    desc: "Edit gem configuration.",
                    type: :boolean,
                    default: false
      method_option :info,
                    aliases: "-i",
                    desc: "Print gem configuration.",
                    type: :boolean,
                    default: false
      def config
        path = configuration.current

        if options.edit? then `#{ENV["EDITOR"]} #{path}`
        elsif options.info?
          path ? say(path) : say("Configuration doesn't exist.")
        else help :config
        end
      end

      desc "-a, [--analyze]", "Analyze feature branch for issues."
      map %w[-a --analyze] => :analyze
      method_option :commits,
                    aliases: "-c",
                    desc: "Analyze specific commit SHA(s).",
                    type: :array,
                    default: []
      def analyze
        # FIX: Need to accept SHAs.
        # collector = analyze_commits options.commits
        collector = analyze_commits
        abort if collector.errors?
      rescue Errors::Base => error
        abort colorizer.red("#{Identity::LABEL}: #{error.message}")
      end

      desc "--hook", "Add Git Hook support."
      map "--hook" => :hook
      method_option :commit_message,
                    desc: "Analyze commit message.",
                    banner: "PATH",
                    type: :string
      def hook
        if options.commit_message?
          check_commit_message options.commit_message
        else
          help "--hook"
        end
      rescue Errors::Base, GitPlus::Errors::Base => error
        abort colorizer.red("#{Identity::LABEL}: #{error.message}")
      end

      desc "-v, [--version]", "Show gem version."
      map %w[-v --version] => :version
      def version
        say Identity::VERSION_LABEL
      end

      desc "-h, [--help=COMMAND]", "Show this message or get help for a command."
      map %w[-h --help] => :help
      def help task = nil
        say and super
      end

      private

      attr_reader :configuration, :runner, :colorizer

      def analyze_commits
        runner.call.tap do |collector|
          reporter = Reporters::Branch.new collector: collector
          say reporter.to_s
        end
      end

      def check_commit_message path
        commit = GitPlus::Repository.new.unsaved Pathname(path)
        collector = runner.call commits: [commit]
        reporter = Reporters::Branch.new collector: collector
        say reporter.to_s
        abort if collector.errors?
      end
    end
  end
end
