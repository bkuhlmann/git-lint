# frozen_string_literal: true

require "dry-container"
require "git_plus"

module Git
  module Lint
    module Commits
      # Provides container specific to this namespace for all systems.
      module Container
        extend Dry::Container::Mixin

        register(:repository) { GitPlus::Repository.new }
        register(:shell) { Open3 }
        register(:environment) { ENV }
      end
    end
  end
end
