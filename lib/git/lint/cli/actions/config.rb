# frozen_string_literal: true

module Git
  module Lint
    module CLI
      module Actions
        # Handles gem configuration action.
        class Config
          def initialize configuration: Configuration::Loader::CLIENT, container: Container
            @configuration = configuration
            @container = container
          end

          def call action
            case action
              when :edit then edit
              when :view then view
              else logger.error { "Invalid configuration action: #{action}." }
            end
          end

          private

          attr_reader :configuration, :container

          def edit = kernel.system("$EDITOR #{configuration.current}")

          def view = kernel.system("cat #{configuration.current}")

          def kernel = container[__method__]

          def logger = container[__method__]
        end
      end
    end
  end
end
