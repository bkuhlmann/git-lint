# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitAuthorName do
  subject(:analyzer) { described_class.new commit: commit }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_author_name)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Author Name")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(enabled: true, severity: :error, minimum: 2)
    end
  end

  describe "#valid?" do
    context "when valid" do
      let(:commit) { GitPlus::Commit[author_name: "Test Example"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with invalid name" do
      let(:commit) { GitPlus::Commit[author_name: "Bogus"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with custom minimum" do
      subject(:analyzer) { described_class.new commit: commit, settings: {minimum: 1} }

      let(:commit) { GitPlus::Commit[author_name: "Example"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[author_name: "Example Tester"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[author_name: "Bogus"] }

      it "answers issue hint" do
        hint = "Author name must consist of 2 parts (minimum)."
        expect(issue[:hint]).to eq(hint)
      end
    end
  end
end
