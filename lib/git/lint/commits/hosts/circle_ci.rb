# frozen_string_literal: true

module Git
  module Lint
    module Commits
      module Hosts
        # Provides Circle CI feature branch information.
        class CircleCI
          include Git::Lint::Import[:git]

          def call = git.commits "origin/#{branch_default}..#{branch_name}"

          private

          def branch_default = git.branch_default.value_or nil

          def branch_name = "origin/#{git.branch_name.value_or nil}"
        end
      end
    end
  end
end
