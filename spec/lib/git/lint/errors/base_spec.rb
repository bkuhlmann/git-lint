# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Errors::Base do
  subject(:error) { described_class.new }

  describe "#message" do
    it "answers default message" do
      expect(error.message).to eq("Invalid Git Lint action.")
    end
  end
end
