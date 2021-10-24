# frozen_string_literal: true

require "refinements/strings"

module Git
  module Lint
    module Commits
      # Automatically detects and loads system.
      class Loader
        using ::Refinements::Strings

        SYSTEMS = {
          circle_ci: Systems::CircleCI.new,
          git_hub_action: Systems::GitHubAction.new,
          netlify_ci: Systems::NetlifyCI.new,
          local: Systems::Local.new
        }.freeze

        def initialize systems: SYSTEMS, container: Container
          @systems = systems
          @container = container
        end

        def call
          message = "Invalid repository. Are you within a Git repository?"
          fail Errors::Base, message unless repository.exist?

          load_system.call
        end

        private

        attr_reader :systems, :container

        def load_system
          if key? "CIRCLECI" then systems.fetch :circle_ci
          elsif key? "GITHUB_ACTIONS" then systems.fetch :git_hub_action
          elsif key? "NETLIFY" then systems.fetch :netlify_ci
          else systems.fetch :local
          end
        end

        def key?(key) = environment.fetch(key, "false").to_bool

        def repository = container[__method__]

        def environment = container[__method__]
      end
    end
  end
end
