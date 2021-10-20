# frozen_string_literal: true

require "open3"

module Git
  module Lint
    module Commits
      module Systems
        # Provides Travis CI build environment feature branch information.
        class TravisCI
          def initialize container: Container
            @container = container
          end

          def call
            prepare_project
            repository.commits "origin/#{repository.branch_default}..#{name}"
          end

          private

          attr_reader :container

          def name = pull_request_branch.empty? ? ci_branch : pull_request_branch

          def prepare_project
            slug = pull_request_slug

            unless slug.empty?
              shell.capture3 "git remote add -f original_branch https://github.com/#{slug}.git"
              shell.capture3 "git fetch original_branch #{name}:#{name}"
            end

            shell.capture3 "git remote set-branches --add origin #{repository.branch_default}"
            shell.capture3 "git fetch"
          end

          def ci_branch = environment["TRAVIS_BRANCH"]

          def pull_request_branch = environment["TRAVIS_PULL_REQUEST_BRANCH"]

          def pull_request_slug = environment["TRAVIS_PULL_REQUEST_SLUG"]

          def repository = container[__method__]

          def shell = container[__method__]

          def environment = container[__method__]
        end
      end
    end
  end
end
