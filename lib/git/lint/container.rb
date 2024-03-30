# frozen_string_literal: true

require "cogger"
require "containable"
require "etcher"
require "gitt"
require "runcom"
require "spek"
require "tone"

module Git
  module Lint
    # Provides a global gem container for injection into other objects.
    module Container
      extend Containable

      namespace :trailers do
        register :collaborator do
          Configuration::Trailer[name: "Co-authored-by", pattern: /\ACo.*authored.*by.*\Z/i]
        end

        register :format do
          Configuration::Trailer[name: "Format", pattern: /\AFormat.*\Z/i]
        end

        register :issue do
          Configuration::Trailer[name: "Issue", pattern: /\AIssue.*\Z/i]
        end

        register :milestone do
          Configuration::Trailer[name: "Milestone", pattern: /\AMilestone.*\Z/i]
        end

        register :reviewer do
          Configuration::Trailer[name: "Reviewer", pattern: /\AReviewer.*\Z/i]
        end

        register :signer do
          Configuration::Trailer[name: "Signed-off-by", pattern: /\ASigned.*off.*by.*\Z/i]
        end

        register :tracker do
          Configuration::Trailer[name: "Tracker", pattern: /\ATracker.*\Z/i]
        end
      end

      namespace :parsers do
        register(:person) { Gitt::Parsers::Person.new }
      end

      namespace :sanitizers do
        register :signature, Gitt::Sanitizers::Signature
      end

      namespace :validators do
        register(:capitalization) { Validators::Capitalization.new }
        register(:email) { Validators::Email.new }
        register(:name) { Validators::Name.new }
        register(:repeated_word) { Validators::RepeatedWord.new }
      end

      namespace :hosts do
        register(:circle_ci) { Commits::Hosts::CircleCI.new }
        register(:git_hub_action) { Commits::Hosts::GitHubAction.new }
        register(:netlify_ci) { Commits::Hosts::NetlifyCI.new }
        register(:local) { Commits::Hosts::Local.new }
      end

      register :configuration do
        self[:defaults].add_loader(Etcher::Loaders::YAML.new(self[:xdg_config].active))
                       .then { |registry| Etcher.call registry }
      end

      register :defaults do
        Etcher::Registry.new(contract: Configuration::Contract, model: Configuration::Model)
                        .add_loader(Etcher::Loaders::YAML.new(self[:defaults_path]))
      end

      register(:defaults_path) { Pathname(__dir__).join("configuration/defaults.yml") }
      register(:specification) { Spek::Loader.call "#{__dir__}/../../../git-lint.gemspec" }
      register(:color) { Tone.new }
      register :environment, ENV
      register(:git) { Gitt::Repository.new }
      register(:xdg_config) { Runcom::Config.new "git-lint/configuration.yml" }
      register(:logger) { Cogger.new id: "git-lint" }
      register :kernel, Kernel
    end
  end
end
