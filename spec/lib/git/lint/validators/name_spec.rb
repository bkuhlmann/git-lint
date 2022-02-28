# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Validators::Name do
  subject(:name) { described_class.new text, delimiter:, minimum: }

  let(:text) { "Example Test" }
  let(:delimiter) { described_class::DEFAULT_DELIMITER }
  let(:minimum) { described_class::DEFAULT_MINIMUM }

  context "with custom delimiter" do
    let(:delimiter) { "-" }
    let(:text) { "Text-Example" }

    it "answers true" do
      expect(name.valid?).to be(true)
    end
  end

  context "with custom minimum" do
    let(:minimum) { 1 }
    let(:text) { "Example" }

    it "answers true" do
      expect(name.valid?).to be(true)
    end
  end

  context "with leading space" do
    let(:text) { " Example Test" }

    it "answers false" do
      expect(name.valid?).to be(false)
    end
  end

  context "with trailing space" do
    let(:text) { "Example Test " }

    it "answers true" do
      expect(name.valid?).to be(true)
    end
  end

  context "with exact minimum" do
    it "answers true" do
      expect(name.valid?).to be(true)
    end
  end

  context "when greater than minimum" do
    let(:text) { "Example Test Tester" }

    it "answers true" do
      expect(name.valid?).to be(true)
    end
  end

  context "when less than minimum" do
    let(:text) { "Example" }

    it "answers false" do
      expect(name.valid?).to be(false)
    end
  end

  context "with empty text" do
    let(:text) { "" }

    it "answers false" do
      expect(name.valid?).to be(false)
    end
  end

  context "with nil text" do
    let(:text) { nil }

    it "answers false" do
      expect(name.valid?).to be(false)
    end
  end
end
