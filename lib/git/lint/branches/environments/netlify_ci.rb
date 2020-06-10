# frozen_string_literal: true

require "open3"

module Git
  module Lint
    module Branches
      module Environments
        # Provides Netlify CI build environment feature branch information.
        class NetlifyCI
          def initialize environment: ENV, repo: Git::Kit::Repo.new, shell: Open3
            @environment = environment
            @repo = repo
            @shell = shell
          end

          def name
            environment["HEAD"]
          end

          def shas
            shell.capture2e "git remote add -f origin #{environment["REPOSITORY_URL"]}"
            shell.capture2e "git fetch origin #{name}:#{name}"
            repo.shas start: "origin/master", finish: "origin/#{name}"
          end

          private

          attr_reader :environment, :repo, :shell
        end
      end
    end
  end
end
