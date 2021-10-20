# frozen_string_literal: true

require "open3"

module Git
  module Lint
    module Commits
      module Systems
        # Provides Netlify CI build environment feature branch information.
        class NetlifyCI
          def initialize container: Container
            @container = container
          end

          def call
            shell.capture3 "git remote add -f origin #{environment["REPOSITORY_URL"]}"
            shell.capture3 "git fetch origin #{name}:#{name}"
            repository.commits "origin/#{repository.branch_default}..origin/#{name}"
          end

          private

          attr_reader :container

          def name = environment["HEAD"]

          def repository = container[__method__]

          def shell = container[__method__]

          def environment = container[__method__]
        end
      end
    end
  end
end
