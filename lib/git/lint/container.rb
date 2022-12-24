# frozen_string_literal: true

require "cogger"
require "dry-container"
require "gitt"
require "spek"

module Git
  module Lint
    # Provides a global gem container for injection into other objects.
    module Container
      extend Dry::Container::Mixin

      register(:configuration) { Configuration::Loader.call }
      register(:environment) { ENV }
      register(:git) { Gitt::Repository.new }
      register(:specification) { Spek::Loader.call "#{__dir__}/../../../git-lint.gemspec" }
      register(:kernel) { Kernel }
      register(:logger) { Cogger::Client.new }

      namespace :trailers do
        register(:collaborator) { /\ACo.*Authored.*By.*\Z/i }
        register(:format) { /\AFormat.*\Z/i }
        register(:issue) { /\AIssue.*\Z/i }
        register(:signer) { /\ASigned.*By.*\Z/i }
        register(:tracker) { /\ATracker.*\Z/i }
      end

      namespace :parsers do
        register(:person) { Gitt::Parsers::Person.new }
      end

      namespace :sanitizers do
        register(:email) { Gitt::Sanitizers::Email }
        register(:signature) { Gitt::Sanitizers::Signature }
      end

      namespace :validators do
        register(:capitalization) { Validators::Capitalization.new }
        register(:email) { Validators::Email.new }
        register(:name) { Validators::Name.new }
      end
    end
  end
end
