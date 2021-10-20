# frozen_string_literal: true

module Git
  module Lint
    module Commits
      module Systems
        # Provides local build environment feature branch information.
        class Local
          def initialize container: Container
            @container = container
          end

          def call = repository.commits("#{repository.branch_default}..#{name}")

          private

          attr_reader :container

          def name = repository.branch_name

          def repository = container[__method__]
        end
      end
    end
  end
end
