# frozen_string_literal: true

require "open3"

module Git
  module Lint
    module Branches
      module Environments
        # Provides Netlify CI build environment feature branch information.
        class NetlifyCI
          def initialize repository: GitPlus::Repository.new, shell: Open3, environment: ENV
            @repository = repository
            @shell = shell
            @environment = environment
          end

          def name
            environment["HEAD"]
          end

          def commits
            shell.capture3 "git remote add -f origin #{environment["REPOSITORY_URL"]}"
            shell.capture3 "git fetch origin #{name}:#{name}"
            repository.commits "origin/#{repository.branch_default}..origin/#{name}"
          end

          private

          attr_reader :repository, :shell, :environment
        end
      end
    end
  end
end
