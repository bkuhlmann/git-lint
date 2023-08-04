# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Validators::Name do
  subject(:validator) { described_class.new }

  describe "#call" do
    it "answers true with custom delimiter" do
      validator = described_class.new delimiter: "-"
      expect(validator.call("Text-Example")).to be(true)
    end

    it "answers true with custom minimum" do
      expect(validator.call("Example", minimum: 1)).to be(true)
    end

    it "answers false with leading space" do
      expect(validator.call(" Example Test")).to be(false)
    end

    it "answers false with multiple spaces between parts" do
      expect(validator.call("Example  Test")).to be(false)
    end

    it "answers true with trailing space" do
      expect(validator.call("Example Test ")).to be(true)
    end

    it "answers true with exact minimum" do
      expect(validator.call("Example Test")).to be(true)
    end

    it "answers true when greater than minimum" do
      expect(validator.call("Example Test Tester")).to be(true)
    end

    it "answers false when less than minimum" do
      expect(validator.call("Example")).to be(false)
    end

    it "answers false with empty content" do
      expect(validator.call("")).to be(false)
    end

    it "answers false with nil content" do
      expect(validator.call(nil)).to be(false)
    end
  end
end
