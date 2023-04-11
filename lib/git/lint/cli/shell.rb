# frozen_string_literal: true

require "core"

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
          :kernel,
          :logger,
          :specification
        ]

        def initialize(parser: Parser.new, **)
          super(**)
          @parser = parser
        end

        def call arguments = Core::EMPTY_ARRAY
          act_on parser.call(arguments)
        rescue OptionParser::ParseError, Errors::Base => error
          logger.error { error.message }
        end

        private

        attr_reader :parser

        def act_on configuration
          case configuration
            in action_analyze: true, analyze_sha: nil then analyze_branch.call
            in action_analyze: true, analyze_sha: String => sha then analyze_commit.call sha
            in action_config: Symbol => action then config.call action
            in action_hook: Pathname => path then hook.call path
            in action_version: true then kernel.puts specification.labeled_version
            else kernel.puts parser.to_s
          end
        end
      end
    end
  end
end
