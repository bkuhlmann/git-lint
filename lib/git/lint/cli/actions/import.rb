# frozen_string_literal: true

require "auto_injector"

module Git
  module Lint
    module CLI
      module Actions
        Import = AutoInjector[Container]
      end
    end
  end
end
