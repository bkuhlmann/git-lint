# frozen_string_literal: true

module Git
  module Lint
    module Commits
      module Hosts
        # Provides local feature branch information.
        class Local
          include Dependencies[:git]

          def call = git.commits "#{branch_default}..#{branch_name}"

          private

          def branch_default = git.branch_default.value_or nil

          def branch_name = git.branch_name.value_or nil
        end
      end
    end
  end
end
