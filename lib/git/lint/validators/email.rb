# frozen_string_literal: true

require "uri"

module Git
  module Lint
    module Validators
      # Validates the format of email addresses.
      class Email
        def initialize pattern: URI::MailTo::EMAIL_REGEXP
          @pattern = pattern
        end

        def call(content) = String(content).match? pattern

        private

        attr_reader :pattern
      end
    end
  end
end
