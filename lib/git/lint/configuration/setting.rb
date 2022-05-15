# frozen_string_literal: true

module Git
  module Lint
    module Configuration
      # Defines analyzer specific settings.
      Setting = Struct.new(
        :delimiter,
        :enabled,
        :excludes,
        :id,
        :includes,
        :maximum,
        :minimum,
        :severity,
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
