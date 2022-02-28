# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Parsers::Trailers::Collaborator do
  subject(:collaborator) { described_class.new text }

  let(:text) { "Co-Authored-By: Test Example <test@example.com>" }

  describe "#key" do
    it "answers key when present" do
      expect(collaborator.key).to eq("Co-Authored-By")
    end

    it "answers empty string when missing" do
      expect(described_class.new("invalid").key).to eq("")
    end
  end

  describe "#name" do
    it "answers name when present" do
      expect(collaborator.name).to eq("Test Example")
    end

    context "with first name and no email" do
      let(:text) { "Co-Authored-By: Test" }

      it "answers first name" do
        expect(collaborator.name).to eq("Test")
      end
    end

    context "with full name and no email" do
      let(:text) { "Co-Authored-By: Test Example" }

      it "answers full name" do
        expect(collaborator.name).to eq("Test Example")
      end
    end

    context "with invalid text" do
      let(:text) { "invalid" }

      it "answers empty string" do
        expect(collaborator.name).to eq("")
      end
    end
  end

  describe "#email" do
    it "answers email when present" do
      expect(collaborator.email).to eq("test@example.com")
    end

    context "with first name and no email" do
      let(:text) { "Co-Authored-By: Test" }

      it "answers empty string" do
        expect(collaborator.email).to eq("")
      end
    end

    context "with full name and no email" do
      let(:text) { "Co-Authored-By: Test Example" }

      it "answers empty string" do
        expect(collaborator.email).to eq("")
      end
    end

    context "with invalid text" do
      let(:text) { "invalid" }

      it "answers empty string" do
        expect(collaborator.email).to eq("")
      end
    end
  end

  describe "#match?" do
    context "with valid text" do
      it "answers true" do
        expect(collaborator.match?).to be(true)
      end
    end

    context "with key only" do
      let(:text) { "Co-Authored-By" }

      it "answers true" do
        expect(collaborator.match?).to be(true)
      end
    end

    context "with mixed case key" do
      let(:text) { "cO-AuThOrEd-bY" }

      it "answers true" do
        expect(collaborator.match?).to be(true)
      end
    end

    context "with malformed key" do
      let(:text) { "CoAuthored  By" }

      it "answers true" do
        expect(collaborator.match?).to be(true)
      end
    end

    context "with key not at start of text" do
      let(:text) { " Co-authored-by" }

      it "answers false" do
        expect(collaborator.match?).to be(false)
      end
    end

    context "with partial key" do
      let(:text) { "Co-authored" }

      it "answers false" do
        expect(collaborator.match?).to be(false)
      end
    end

    context "with no collaborator information" do
      let(:text) { "Some random text." }

      it "answers false" do
        expect(collaborator.match?).to be(false)
      end
    end

    context "with empty text" do
      let(:text) { "" }

      it "answers false" do
        expect(collaborator.match?).to be(false)
      end
    end

    context "with nil text" do
      let(:text) { nil }

      it "answers false" do
        expect(collaborator.match?).to be(false)
      end
    end

    context "with non-string text" do
      let(:text) { 123 }

      it "answers false" do
        expect(collaborator.match?).to be(false)
      end
    end
  end
end
