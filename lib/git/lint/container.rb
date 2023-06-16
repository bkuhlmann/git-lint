# frozen_string_literal: true

require "cogger"
require "dry-container"
require "etcher"
require "gitt"
require "runcom"
require "spek"
require "tone"

module Git
  module Lint
    # Provides a global gem container for injection into other objects.
    module Container
      extend Dry::Container::Mixin

      register :configuration do
        self[:defaults].add_loader(Etcher::Loaders::YAML.new(self[:xdg_config].active))
                       .then { |registry| Etcher.call registry }
      end

      register :defaults do
        Etcher::Registry.new(contract: Configuration::Contract, model: Configuration::Model)
                        .add_loader(Etcher::Loaders::YAML.new(self[:defaults_path]))
      end

      register(:color) { Tone.new }
      register(:environment) { ENV }
      register(:git) { Gitt::Repository.new }
      register(:defaults_path) { Pathname(__dir__).join("configuration/defaults.yml") }
      register(:xdg_config) { Runcom::Config.new "git-lint/configuration.yml" }
      register(:specification) { Spek::Loader.call "#{__dir__}/../../../git-lint.gemspec" }
      register(:kernel) { Kernel }
      register(:logger) { Cogger.new formatter: :emoji }

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
