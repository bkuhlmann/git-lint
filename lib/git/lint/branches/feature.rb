# frozen_string_literal: true

require "forwardable"
require "refinements/strings"

module Git
  module Lint
    module Branches
      # Represents a feature branch.
      class Feature
        extend Forwardable

        using ::Refinements::Strings

        def_delegators :selected_environment, :name, :commits

        def initialize environment: ENV, git_repo: GitPlus::Repository.new
          message = "Invalid repository. Are you within a Git-enabled project?"
          fail Errors::Base, message unless git_repo.exist?

          @current_environment = environment
          @selected_environment = load_environment
        end

        private

        attr_reader :current_environment, :selected_environment

        def load_environment
          if key? "CIRCLECI" then Environments::CircleCI.new
          elsif key? "GITHUB_ACTIONS" then Environments::GitHubAction.new
          elsif key? "NETLIFY" then Environments::NetlifyCI.new environment: current_environment
          elsif key? "TRAVIS" then Environments::TravisCI.new environment: current_environment
          else Environments::Local.new
          end
        end

        def key?(key) = current_environment.fetch(key, "false").to_bool
      end
    end
  end
end
