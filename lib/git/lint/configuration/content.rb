# frozen_string_literal: true

module Git
  module Lint
    module Configuration
      # Defines configuration content as the primary source of truth for use throughout the gem.
      Content = Struct.new(
        :action_analyze,
        :action_config,
        :action_help,
        :action_hook,
        :action_version,
        :analyze_shas,
        :analyzers,
        keyword_init: true
      ) do
        def initialize *arguments
          super
          freeze
        end
      end
    end
  end
end