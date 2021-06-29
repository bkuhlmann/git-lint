# frozen_string_literal: true

module Git
  module Lint
    module Branches
      module Environments
        # Provides GitHub Action build environment feature branch information.
        class GitHubAction
          def initialize repository: GitPlus::Repository.new
            @repository = repository
          end

          def name = "origin/#{repository.branch_name}"

          def commits = repository.commits("origin/#{repository.branch_default}..#{name}")

          private

          attr_reader :repository
        end
      end
    end
  end
end
