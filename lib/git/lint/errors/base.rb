# frozen_string_literal: true

module Git
  module Lint
    module Errors
      # The root class of gem related errors.
      class Base < StandardError
        def initialize message = "Invalid Git Lint action."
          super message
        end
      end
    end
  end
end
