# frozen_string_literal: true

require "cogger"
require "dry-container"
require "git_plus"
require "open3"
require "spek"

module Git
  module Lint
    # Provides a global gem container for injection into other objects.
    module Container
      extend Dry::Container::Mixin

      register(:configuration) { Configuration::Loader.call }
      register(:environment) { ENV }
      register(:repository) { GitPlus::Repository.new }
      register(:specification) { Spek::Loader.call "#{__dir__}/../../../git-lint.gemspec" }
      register(:kernel) { Kernel }
      register(:executor) { Open3 }
      register(:logger) { Cogger::Client.new }
    end
  end
end
