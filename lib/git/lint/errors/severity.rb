# frozen_string_literal: true

module Git
  module Lint
    module Errors
      class Severity < Base
        def initialize level
          super %(Invalid severity level: #{level}. Use: #{Analyzers::Abstract::LEVELS.join ", "}.)
        end
      end
    end
  end
end
