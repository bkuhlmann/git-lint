# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSubjectSuffix do
  subject(:analyzer) { described_class.new commit: commit }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_subject_suffix)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Subject Suffix")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error,
        excludes: ["\\.", "\\?", "\\!"]
      )
    end
  end

  describe "#valid?" do
    context "when valid" do
      let(:commit) { GitPlus::Commit[subject: "Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with period" do
      let(:commit) { GitPlus::Commit[subject: "Added specs."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with question mark" do
      let(:commit) { GitPlus::Commit[subject: "Added specs?"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with exclamation mark" do
      let(:commit) { GitPlus::Commit[subject: "Added specs!"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with custom exclude list" do
      subject(:analyzer) { described_class.new commit: commit, settings: {excludes: ["😅"]} }

      let(:commit) { GitPlus::Commit[subject: "Added specs 😅"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with empty exclude list" do
      subject(:analyzer) { described_class.new commit: commit, settings: {excludes: []} }

      let(:commit) { GitPlus::Commit[subject: "Added specs?"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[subject: "Added specs"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[subject: "Added specs?"] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Avoid: /\\./, /\\?/, /\\!/.")
      end
    end
  end
end
