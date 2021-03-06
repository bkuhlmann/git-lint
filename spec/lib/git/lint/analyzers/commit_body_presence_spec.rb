# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyPresence do
  subject(:analyzer) { described_class.new commit: commit }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_presence)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Presence")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let(:commit) { GitPlus::Commit[subject: "Test", body_lines: ["Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "when valid (custom minimum)" do
      subject :analyzer do
        described_class.new commit: commit, settings: described_class.defaults.merge(minimum: 3)
      end

      let(:commit) { GitPlus::Commit[subject: "Test", body_lines: ["One.", "Two.", "Three."]] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "when valid (fixup!)" do
      let(:commit) { GitPlus::Commit[subject: "fixup! Test", body_lines: ["Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "when invalid (empty)" do
      let(:commit) { GitPlus::Commit[subject: "Test", body_lines: [""]] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "when invalid (custom minimum and not enough non-empty lines)" do
      subject :analyzer do
        described_class.new commit: commit, settings: described_class.defaults.merge(minimum: 3)
      end

      let :commit do
        GitPlus::Commit[subject: "Test", body_lines: ["One.", "\r", "", "\t", "Two."]]
      end

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[subject: "Test", body_lines: ["Test."]] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      subject :analyzer do
        described_class.new commit: commit, settings: described_class.defaults.merge(minimum: 3)
      end

      let :commit do
        GitPlus::Commit[subject: "Test", body_lines: ["One.", "\r", " ", "\t", "Two."]]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use minimum of 3 lines (non-empty).")
      end
    end
  end
end
