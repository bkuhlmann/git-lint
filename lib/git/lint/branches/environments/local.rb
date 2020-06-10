# frozen_string_literal: true

module Git
  module Lint
    module Branches
      module Environments
        # Provides local build environment feature branch information.
        class Local
          def initialize repo: Git::Kit::Repo.new
            @repo = repo
          end

          def name
            repo.branch_name
          end

          def shas
            repo.shas start: "master", finish: name
          end

          private

          attr_reader :repo
        end
      end
    end
  end
end
