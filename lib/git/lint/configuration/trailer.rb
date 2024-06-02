# frozen_string_literal: true

module Git
  module Lint
    module Configuration
      # Defines trailer configuration as a subset of the primary settings.
      Trailer = Data.define :name, :pattern
    end
  end
end
