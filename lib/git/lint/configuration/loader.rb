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
        HANDLER = Runcom::Config.new "#{Identity::NAME}/configuration.yml", defaults: DEFAULTS

        def self.call = new.call

        def self.with_defaults = new(handler: DEFAULTS)

        def initialize content: Content.new, handler: HANDLER
          @content = content
          @handler = handler
        end

        def call
          handler.to_h
                 .then do |raw|
                   content.merge(**raw.slice(:analyzers), **raw.except(:analyzers).flatten_keys)
                          .freeze
                 end
        end

        private

        attr_reader :content, :handler
      end
    end
  end
end
