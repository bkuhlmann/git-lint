# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitAuthorCapitalization do
  subject(:analyzer) { described_class.new commit: commit }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_author_capitalization)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Author Capitalization")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(enabled: true, severity: :error)
    end
  end

  describe "#valid?" do
    context "with capitalization" do
      let(:commit) { GitPlus::Commit[author_name: "Example Test"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "without capitalization" do
      let(:commit) { GitPlus::Commit[author_name: "Example test"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with custom minimum" do
      let(:commit) { GitPlus::Commit[author_name: "Example"] }
      let(:settings) { {enabled: true, minimum: 1} }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[author_name: "Example Test"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[author_name: "example"] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq(%(Capitalize each part of name: "example".))
      end
    end
  end
end
