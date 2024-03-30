# frozen_string_literal: true

require "refinements/string"

module Git
  module Lint
    module Commits
      # Automatically detects and loads host.
      class Loader
        include Import[
          :git,
          :environment,
          circle_ci: "hosts.circle_ci",
          git_hub_action: "hosts.git_hub_action",
          netlify_ci: "hosts.git_hub_action",
          local: "hosts.local"
        ]

        using Refinements::String

        def call
          message = "Invalid repository. Are you within a Git repository?"
          fail Errors::Base, message unless git.exist?

          host.call
        end

        private

        def host
          if key? "CIRCLECI" then circle_ci
          elsif key? "GITHUB_ACTIONS" then git_hub_action
          elsif key? "NETLIFY" then netlify_ci
          else local
          end
        end

        def key?(key) = environment.fetch(key, "false").to_bool
      end
    end
  end
end
