# frozen_string_literal: true

require "open3"

module Git
  module Lint
    module Commits
      module Systems
        # Provides Netlify CI build environment feature branch information.
        class NetlifyCI
          include Git::Lint::Import[:repository, :executor, :environment]

          def call
            executor.capture3 "git remote add -f origin #{environment["REPOSITORY_URL"]}"
            executor.capture3 "git fetch origin #{name}:#{name}"
            repository.commits "origin/#{repository.branch_default}..origin/#{name}"
          end

          private

          def name = environment["HEAD"]
        end
      end
    end
  end
end
