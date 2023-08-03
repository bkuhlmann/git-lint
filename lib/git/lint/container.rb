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

      namespace :trailers do
        register(:collaborator, memoize: true) { /\ACo.*Authored.*By.*\Z/i }
        register(:format, memoize: true) { /\AFormat.*\Z/i }
        register(:issue, memoize: true) { /\AIssue.*\Z/i }

        register :milestone, memoize: true do
          Configuration::Trailer[name: "Milestone", pattern: /\AMilestone.*\Z/i]
        end

        register :reviewer, memoize: true do
          Configuration::Trailer[name: "Reviewer", pattern: /\AReviewer.*\Z/i]
        end

        register(:signer, memoize: true) { /\ASigned.*By.*\Z/i }
        register(:tracker, memoize: true) { /\ATracker.*\Z/i }
      end

      namespace :parsers do
        register(:person, memoize: true) { Gitt::Parsers::Person.new }
      end

      namespace :sanitizers do
        register(:signature) { Gitt::Sanitizers::Signature }
      end

      namespace :validators do
        register(:capitalization, memoize: true) { Validators::Capitalization.new }
        register(:email, memoize: true) { Validators::Email.new }
        register(:name, memoize: true) { Validators::Name.new }
      end

      register :configuration, memoize: true do
        self[:defaults].add_loader(Etcher::Loaders::YAML.new(self[:xdg_config].active))
                       .then { |registry| Etcher.call registry }
      end

      register :defaults, memoize: true do
        Etcher::Registry.new(contract: Configuration::Contract, model: Configuration::Model)
                        .add_loader(Etcher::Loaders::YAML.new(self[:defaults_path]))
      end

      register :defaults_path, memoize: true do
        Pathname(__dir__).join("configuration/defaults.yml")
      end

      register :specification, memoize: true do
        Spek::Loader.call "#{__dir__}/../../../git-lint.gemspec"
      end

      register(:color, memoize: true) { Tone.new }
      register(:environment) { ENV }
      register(:git, memoize: true) { Gitt::Repository.new }
      register(:xdg_config, memoize: true) { Runcom::Config.new "git-lint/configuration.yml" }
      register(:logger, memoize: true) { Cogger.new id: "git-lint" }
      register :kernel, Kernel
    end
  end
end
