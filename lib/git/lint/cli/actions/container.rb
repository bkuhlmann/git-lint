# frozen_string_literal: true

require "dry/container"

module Git
  module Lint
    module CLI
      module Actions
        # Provides a single container with application and action specific dependencies.
        module Container
          extend Dry::Container::Mixin

          merge Git::Lint::Container

          register(:analyze_branch) { Analyze::Branch.new }
          register(:analyze_commit) { Analyze::Commit.new }
          register(:config) { Config.new }
          register(:hook) { Hook.new }
        end
      end
    end
  end
end
