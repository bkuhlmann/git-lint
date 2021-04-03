# frozen_string_literal: true

module Git
  module Lint
    module Branches
      module Environments
        # Provides Circle CI build environment feature branch information.
        class CircleCI
          def initialize repository: GitPlus::Repository.new
            @repository = repository
          end

          def name
            "origin/#{repository.branch_name}"
          end

          def commits
            repository.commits "origin/#{repository.branch_default}..#{name}"
          end

          private

          attr_reader :repository
        end
      end
    end
  end
end
