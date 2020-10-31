# frozen_string_literal: true

require "forwardable"

module Git
  module Lint
    module Branches
      # Represents a feature branch.
      class Feature
        extend Forwardable

        def_delegators :selected_environment, :name, :shas

        def initialize environment: ENV, git_repo: Git::Kit::Repo.new
          message = "Invalid repository. Are you within a Git-enabled project?"
          fail Errors::Base, message unless git_repo.exist?

          @current_environment = environment
          @selected_environment = load_environment
        end

        def commits
          shas.map { |sha| Commits::Saved.new sha: sha }
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

        def key? key
          current_environment[key] == "true"
        end
      end
    end
  end
end
