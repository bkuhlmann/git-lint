# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Validators::Email do
  subject(:validator) { described_class.new }

  describe "#valid?" do
    it "answers true with valid validator" do
      expect(validator.call("test@example.com")).to be(true)
    end

    it "answers true with minimum requirements" do
      expect(validator.call("a@b.c")).to be(true)
    end

    it "answers true with subdomain" do
      expect(validator.call("test@sub.example.com")).to be(true)
    end

    it "answers false with special characters" do
      expect(validator.call("test@invalid!~#$%^&*(){}[].com")).to be(false)
    end

    it "answers false with missing '@' symbol" do
      expect(validator.call("example.com")).to be(false)
    end
  end
end
