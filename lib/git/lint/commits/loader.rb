# frozen_string_literal: true

require "refinements/strings"

module Git
  module Lint
    module Commits
      # Automatically detects and loads system.
      class Loader
        include Systems::Import[
          :circle_ci,
          :git_hub_action,
          :netlify_ci,
          :local,
          :repository,
          :environment
        ]

        using ::Refinements::Strings

        def call
          message = "Invalid repository. Are you within a Git repository?"
          fail Errors::Base, message unless repository.exist?

          load_system.call
        end

        private

        def load_system
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
