# frozen_string_literal: true

module Git
  module Lint
    module Branches
      module Environments
        # Provides Circle CI build environment feature branch information.
        class CircleCI
          def initialize repo: Git::Kit::Repo.new
            @repo = repo
          end

          def name
            "origin/#{repo.branch_name}"
          end

          def shas
            repo.shas start: "origin/master", finish: name
          end

          private

          attr_reader :repo
        end
      end
    end
  end
end
