# frozen_string_literal: true

require "sod"

module Git
  module Lint
    module CLI
      # The main Command Line Interface (CLI) object.
      class Shell
        include Dependencies[:defaults_path, :xdg_config, :specification]

        def initialize(context: Sod::Context, dsl: Sod, **)
          super(**)
          @context = context
          @dsl = dsl
        end

        def call(...) = cli.call(...)

        private

        attr_reader :context, :dsl

        def cli
          context = build_context

          dsl.new "git-lint", banner: specification.banner do
            on(Sod::Prefabs::Commands::Config, context:)

            on "analyze", "Analyze branch or commit(s)." do
              on Actions::Analyze::Branch
              on Actions::Analyze::Commit
            end

            on Actions::Hook
            on(Sod::Prefabs::Actions::Version, context:)
            on Sod::Prefabs::Actions::Help, self
          end
        end

        def build_context
          context[defaults_path:, xdg_config:, version_label: specification.labeled_version]
        end
      end
    end
  end
end
