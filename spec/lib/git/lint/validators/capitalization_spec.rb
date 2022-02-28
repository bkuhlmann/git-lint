# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Validators::Capitalization do
  subject(:capitalization) { described_class.new text, delimiter:, pattern: }

  let(:delimiter) { Git::Lint::Validators::Name::DEFAULT_DELIMITER }
  let(:pattern) { described_class::DEFAULT_PATTERN }

  describe "#valid?" do
    context "with custom delimiter" do
      let(:delimiter) { "-" }
      let(:text) { "Text-Example" }

      it "answers true" do
        expect(capitalization.valid?).to be(true)
      end
    end

    context "with custom pattern" do
      let(:pattern) { /[[:upper:]].+/ }
      let(:text) { "Test Example" }

      it "answers true" do
        expect(capitalization.valid?).to be(true)
      end
    end

    context "with leading space, capitalized" do
      let(:text) { " Example" }

      it "answers false" do
        expect(capitalization.valid?).to be(false)
      end
    end

    context "with single name, capitalized" do
      let(:text) { "Example" }

      it "answers true" do
        expect(capitalization.valid?).to be(true)
      end
    end

    context "with single name, uncapitalized" do
      let(:text) { "example" }

      it "answers false" do
        expect(capitalization.valid?).to be(false)
      end
    end

    context "with single letter, capitalized" do
      let(:text) { "E" }

      it "answers true" do
        expect(capitalization.valid?).to be(true)
      end
    end

    context "with single letter, uncapitalized" do
      let(:text) { "e" }

      it "answers false" do
        expect(capitalization.valid?).to be(false)
      end
    end

    context "with multiple parts, all capitalized" do
      let(:text) { "Example Tester" }

      it "answers true" do
        expect(capitalization.valid?).to be(true)
      end
    end

    context "with multiple parts, mixed capitalized" do
      let(:text) { "Example tester" }

      it "answers false" do
        expect(capitalization.valid?).to be(false)
      end
    end

    context "with nil text" do
      let(:text) { nil }

      it "answers true" do
        expect(capitalization.valid?).to be(true)
      end
    end
  end
end
