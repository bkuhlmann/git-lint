# frozen_string_literal: true

require "auto_injector"

module Git
  module Lint
    Import = AutoInjector[Container]
  end
end
