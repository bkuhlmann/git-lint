# frozen_string_literal: true

require "refinements/array"

module Git
  module Lint
    module Errors
      # Categorizes severity errors.
      class Severity < Base
        using Refinements::Array

        def initialize level
          usage = Analyzers::Abstract::LEVELS.to_usage "or"
          super %(Invalid severity level: #{level}. Use: #{usage}.)
        end
      end
    end
  end
end
