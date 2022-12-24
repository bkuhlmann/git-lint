# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Validators::Capitalization do
  subject(:validator) { described_class.new }

  describe "#valid?" do
    it "answers true with custom delimiter" do
      validator = described_class.new delimiter: "-"
      expect(validator.call("Text-Example")).to be(true)
    end

    it "answers true with custom pattern" do
      validator = described_class.new pattern: /[[:upper:]].+/
      expect(validator.call("Test Example")).to be(true)
    end

    it "answers false with leading space" do
      expect(validator.call(" Example")).to be(false)
    end

    it "answers true with single name capitalized" do
      expect(validator.call("Example")).to be(true)
    end

    it "answers false with single name lowercased" do
      expect(validator.call("example")).to be(false)
    end

    it "answers false with single name that starts with a number" do
      expect(validator.call("1Example")).to be(false)
    end

    it "answers false with single name that starts with a special character" do
      expect(validator.call("@Example")).to be(false)
    end

    it "answers true with single letter capitalized" do
      expect(validator.call("E")).to be(true)
    end

    it "answers false with single letter lowercased" do
      expect(validator.call("e")).to be(false)
    end

    it "answers true with multiple parts capitalized" do
      expect(validator.call("Example Tester")).to be(true)
    end

    it "answers false with multiple parts and only first capitalized" do
      expect(validator.call("Example tester")).to be(false)
    end

    it "answers false with multiple parts and without last capitalized" do
      expect(validator.call("example Tester")).to be(false)
    end

    it "answers true with nil text" do
      expect(validator.call(nil)).to be(true)
    end
  end
end
