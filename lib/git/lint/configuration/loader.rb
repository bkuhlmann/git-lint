# frozen_string_literal: true

require "pathname"
require "refinements/hashes"
require "refinements/structs"
require "runcom"
require "yaml"

module Git
  module Lint
    module Configuration
      # Represents the fully assembled Command Line Interface (CLI) configuration.
      class Loader
        using ::Refinements::Hashes
        using ::Refinements::Structs

        DEFAULTS = YAML.load_file(Pathname(__dir__).join("defaults.yml")).freeze
        CLIENT = Runcom::Config.new "git-lint/configuration.yml", defaults: DEFAULTS

        def self.call = new.call

        def self.with_defaults = new(client: DEFAULTS)

        def initialize content: Content.new, client: CLIENT, setting: Setting
          @content = content
          @client = client
          @setting = setting
        end

        def call
          client.to_h
                .then do |defaults|
                  content.merge(
                    **defaults.except(:analyzers).flatten_keys,
                    analyzers: load_analyzer_settings(defaults)
                  ).freeze
                end
        end

        private

        attr_reader :content, :client, :setting

        def load_analyzer_settings defaults
          defaults.fetch(:analyzers).map { |id, body| setting[id:, **body] }
        end
      end
    end
  end
end
