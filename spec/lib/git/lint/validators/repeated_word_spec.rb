# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Validators::RepeatedWord do
  subject(:validator) { described_class.new }

  describe "#call" do
    it "answers repeats with custom pattern" do
      validator = described_class.new pattern: /\d+/
      expect(validator.call("1 1 2")).to contain_exactly("1")
    end

    it "answers duplicated word at start of content" do
      expect(validator.call("This this is a test")).to contain_exactly("this")
    end

    it "answers duplicated word at end of content" do
      expect(validator.call("This is a test test")).to contain_exactly("test")
    end

    it "answers duplicated word" do
      expect(validator.call("This is is a test")).to contain_exactly("is")
    end

    it "answers duplicated word for each pair" do
      expect(validator.call("This is is is a test")).to eq(%w[is is])
    end

    it "answers repeated, mixed case, words" do
      expect(validator.call("This is IS iS a test")).to eq(%w[IS iS])
    end

    it "answers empty array with no repeats" do
      expect(validator.call("This a test")).to eq([])
    end

    it "answers empty array with word boundaries respected" do
      expect(validator.call("link:https://test.com/test[Test]")).to eq([])
    end

    it "answers empty array when content has no words" do
      expect(validator.call("1 2 3")).to eq([])
    end

    it "answers empty array when content is empty" do
      expect(validator.call("")).to eq([])
    end

    it "answers empty array when content is nil" do
      expect(validator.call(nil)).to eq([])
    end
  end
end
