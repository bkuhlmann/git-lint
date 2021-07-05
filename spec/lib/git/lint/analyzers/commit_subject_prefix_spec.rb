# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSubjectPrefix do
  subject(:analyzer) { described_class.new commit: commit }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_subject_prefix)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Subject Prefix")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error,
        includes: %w[Fixed Added Updated Removed Refactored]
      )
    end
  end

  describe "#valid?" do
    context "with valid prefix" do
      let(:commit) { GitPlus::Commit[subject: "Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with custom include list" do
      subject(:analyzer) { described_class.new commit: commit, settings: {includes: %w[One Two]} }

      let(:commit) { GitPlus::Commit[subject: "One"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with empty include list" do
      subject(:analyzer) { described_class.new commit: commit, settings: {includes: []} }

      let(:commit) { GitPlus::Commit[subject: "Test"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with amend" do
      let(:commit) { GitPlus::Commit[subject: "amend! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with fixup" do
      let(:commit) { GitPlus::Commit[subject: "fixup! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with squash" do
      let(:commit) { GitPlus::Commit[subject: "squash! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with invalid prefix" do
      let(:commit) { GitPlus::Commit[subject: "Bogus"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[subject: "Added specs"] }

      it "answers empty string" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[subject: "Bogus"] }

      it "answres issue hint" do
        expect(issue[:hint]).to eq("Use: /Fixed/, /Added/, /Updated/, /Removed/, /Refactored/.")
      end
    end
  end
end
