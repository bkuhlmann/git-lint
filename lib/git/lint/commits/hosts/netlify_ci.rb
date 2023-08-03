# frozen_string_literal: true

module Git
  module Lint
    module Commits
      module Hosts
        # Provides Netlify CI feature branch information.
        class NetlifyCI
          include Git::Lint::Import[:git, :environment]

          def call
            git.call("remote", "add", "-f", "origin", environment["REPOSITORY_URL"])
               .bind { git.call "fetch", "origin", "#{branch_name}:#{branch_name}" }
               .bind { git.commits "origin/#{branch_default}..origin/#{branch_name}" }
          end

          private

          def branch_default = git.branch_default.value_or nil

          def branch_name = environment["HEAD"]
        end
      end
    end
  end
end
