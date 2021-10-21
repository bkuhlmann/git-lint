# frozen_string_literal: true

require "uri"

module Git
  module Lint
    module Validators
      # Validates the format of email addresses.
      class Email
        def initialize text, pattern: URI::MailTo::EMAIL_REGEXP
          @text = text
          @pattern = pattern
        end

        def valid? = String(text).match?(pattern)

        private

        attr_reader :text, :pattern
      end
    end
  end
end
