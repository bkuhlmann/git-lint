# frozen_string_literal: true

module Git
  module Lint
    module CLI
      # The main Command Line Interface (CLI) object.
      class Shell
        include Actions::Import[
          :analyze_branch,
          :analyze_commit,
          :config,
          :hook,
          :specification,
          :logger
        ]

        def initialize parser: Parser.new, **dependencies
          super(**dependencies)
          @parser = parser
        end

        def call arguments = []
          perform parser.call(arguments)
        rescue OptionParser::ParseError, Errors::Base => error
          logger.error { error.message }
        end

        private

        attr_reader :parser

        def perform configuration
          case configuration
            in action_analyze: true, analyze_sha: nil then analyze_branch.call
            in action_analyze: true, analyze_sha: String => sha then analyze_commit.call sha
            in action_config: Symbol => action then config.call action
            in action_hook: Pathname => path then hook.call path
            in action_version: true then logger.info { specification.labeled_version }
            else logger.any { parser.to_s }
          end
        end
      end
    end
  end
end
