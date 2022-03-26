# frozen_string_literal: true

require "dry/container"

module Git
  module Lint
    module Commits
      module Systems
        # Provides a single container with application and system specific dependencies.
        module Container
          extend Dry::Container::Mixin

          config.registry = ->(container, key, value, _options) { container[key.to_s] = value }

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
