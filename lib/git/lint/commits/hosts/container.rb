# frozen_string_literal: true

require "containable"

module Git
  module Lint
    module Commits
      module Hosts
        # Provides a single container with application and host specific dependencies.
        module Container
          extend Containable

          merge Git::Lint::Container

          register(:circle_ci) { CircleCI.new }
          register(:git_hub_action) { GitHubAction.new }
          register(:netlify_ci) { NetlifyCI.new }
          register(:local) { Local.new }
        end
      end
    end
  end
end
