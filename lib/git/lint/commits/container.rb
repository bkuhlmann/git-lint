# frozen_string_literal: true

require "dry-container"
require "git_plus"

module Git
  module Lint
    module Commits
      # Provides container specific to this namespace for all systems.
      module Container
        extend Dry::Container::Mixin

        config.registry = ->(container, key, value, _options) { container[key.to_s] = value }

        merge Git::Lint::Container

        register(:shell) { Open3 }
      end
    end
  end
end
