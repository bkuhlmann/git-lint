# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Errors::Severity do
  describe "#message" do
    subject(:error) { described_class.new :bogus }

    it "answers default message" do
      expect(error.message).to eq(%(Invalid severity level: bogus. Use: "warn" or "error".))
    end
  end
end
