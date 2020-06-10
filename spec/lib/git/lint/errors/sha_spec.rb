# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Errors::SHA do
  describe "#message" do
    subject(:sha_error) { described_class.new "bogus" }

    it "answers default message" do
      expect(sha_error.message).to eq(
        %(Invalid commit SHA: "bogus". Unable to obtain commit details.)
      )
    end
  end
end
