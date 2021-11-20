# frozen_string_literal: true

module Git
  module Lint
    module CLI
      # The main Command Line Interface (CLI) object.
      class Shell
        ACTIONS = {
          analyze_branch: Actions::Analyze::Branch.new,
          analyze_commit: Actions::Analyze::Commit.new,
          config: Actions::Config.new,
          hook: Actions::Hook.new
        }.freeze

        def initialize parser: Parser.new, actions: ACTIONS, container: Container
          @parser = parser
          @actions = actions
          @container = container
        end

        def call arguments = []
          perform parser.call(arguments)
        rescue OptionParser::ParseError, Errors::Base => error
          logger.error { error.message }
        end

        private

        attr_reader :parser, :actions, :container

        def perform configuration
          case configuration
            in action_analyze: true, analyze_shas: nil then analyze_branch
            in action_analyze: true, analyze_shas: Array => shas then analyze_commit shas
            in action_config: Symbol => action then config action
            in action_hook: Pathname => path then hook path
            in action_version: String => version then logger.info version
            else usage
          end
        end

        def analyze_branch = actions.fetch(__method__).call

        def analyze_commit(shas) = actions.fetch(__method__).call(shas)

        def config(action) = actions.fetch(__method__).call(action)

        def hook(path) = actions.fetch(__method__).call(path)

        def usage = logger.unknown { parser.to_s }

        def logger = container[__method__]
      end
    end
  end
end