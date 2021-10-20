# frozen_string_literal: true

module Git
  module Lint
    module Commits
      module Systems
        # Provides Circle CI build environment feature branch information.
        class CircleCI
          def initialize container: Container
            @container = container
          end

          def call = repository.commits("origin/#{repository.branch_default}..#{name}")

          private

          attr_reader :container

          def name = "origin/#{repository.branch_name}"

          def repository = container[__method__]
        end
      end
    end
  end
end
