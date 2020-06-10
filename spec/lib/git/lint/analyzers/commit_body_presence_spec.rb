# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyPresence do
  subject(:analyzer) { described_class.new commit: commit, settings: settings }

  let(:fixup) { false }
  let(:body_lines) { ["Curabitur eleifend wisi iaculis ipsum."] }
  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell),
                  body_lines: body_lines,
                  fixup?: fixup
  end

  let(:minimum) { 1 }
  let(:settings) { {enabled: true, minimum: minimum} }

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
      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "when valid (custom minimum)" do
      let(:minimum) { 3 }
      let(:body_lines) { ["First line.", "Second line", "", "Third line."] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "when valid (fixup!)" do
      let(:body_lines) { [] }
      let(:fixup) { true }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "when invalid (empty)" do
      let(:body_lines) { [""] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "when invalid (custom minimum & not enough non-empty lines)" do
      let(:minimum) { 3 }
      let(:body_lines) { ["First line.", "\r", "", "\t", "Second one here."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:minimum) { 3 }
      let(:body_lines) { ["First line.", "\r", " ", "\t", "Second one here."] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use minimum of 3 lines (non-empty).")
      end
    end
  end
end
