# frozen_string_literal: true

module Git
  module Lint
    module Branches
      module Environments
        # Provides local build environment feature branch information.
        class Local
          def initialize repository: GitPlus::Repository.new
            @repository = repository
          end

          def name
            repository.branch_name
          end

          def commits
            repository.commits "master..#{name}"
          end

          private

          attr_reader :repository
        end
      end
    end
  end
end
