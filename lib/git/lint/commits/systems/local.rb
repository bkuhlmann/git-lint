# frozen_string_literal: true

module Git
  module Lint
    module Commits
      module Systems
        # Provides local build environment feature branch information.
        class Local
          include Git::Lint::Import[:repository]

          def call = repository.commits("#{repository.branch_default}..#{name}")

          private

          def name = repository.branch_name
        end
      end
    end
  end
end
