# frozen_string_literal: true

require "open3"

module Git
  module Lint
    module Branches
      module Environments
        # Provides Travis CI build environment feature branch information.
        class TravisCI
          def initialize repository: GitPlus::Repository.new, shell: Open3, environment: ENV
            @repository = repository
            @shell = shell
            @environment = environment
          end

          def name
            pull_request_branch.empty? ? ci_branch : pull_request_branch
          end

          def commits
            prepare_project
            repository.commits "origin/master..#{name}"
          end

          private

          attr_reader :environment, :repository, :shell

          def prepare_project
            slug = pull_request_slug

            unless slug.empty?
              shell.capture3 "git remote add -f original_branch https://github.com/#{slug}.git"
              shell.capture3 "git fetch original_branch #{name}:#{name}"
            end

            shell.capture3 "git remote set-branches --add origin master"
            shell.capture3 "git fetch"
          end

          def ci_branch
            environment["TRAVIS_BRANCH"]
          end

          def pull_request_branch
            environment["TRAVIS_PULL_REQUEST_BRANCH"]
          end

          def pull_request_slug
            environment["TRAVIS_PULL_REQUEST_SLUG"]
          end
        end
      end
    end
  end
end
