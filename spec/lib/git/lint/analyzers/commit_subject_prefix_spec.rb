# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSubjectPrefix do
  subject(:analyzer) { described_class.new commit: commit, settings: settings }

  let(:content) { "Added test file." }
  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell), subject: content
  end

  let(:settings) { {enabled: true, includes: %w[Added Removed Fixed]} }

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
    context "with no issues" do
      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with empty include list" do
      let(:include) { [] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with unsaved fixup commit" do
      let(:content) { "fixup! Added test file." }

      before do
        allow(commit).to receive(:is_a?).with(Git::Lint::Commits::Unsaved).and_return(true)
        allow(commit).to receive(:fixup?).and_return(true)
      end

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with unsaved squash commit" do
      let(:content) { "squash! Added test file." }

      before do
        allow(commit).to receive(:is_a?).with(Git::Lint::Commits::Unsaved).and_return(true)
        allow(commit).to receive(:fixup?).and_return(false)
        allow(commit).to receive(:squash?).and_return(true)
      end

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with invalid prefix" do
      let(:content) { "Bogus subject line." }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with saved fixup commit" do
      let(:content) { "fixup! Added test file." }

      before do
        allow(commit).to receive(:is_a?).with(Git::Lint::Commits::Unsaved).and_return(false)
      end

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with saved squash commit" do
      let(:content) { "squash! Added test file." }

      before do
        allow(commit).to receive(:is_a?).with(Git::Lint::Commits::Unsaved).and_return(false)
      end

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      it "answers empty string" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:content) { "Bogus subject line." }

      it "answres issue hint" do
        expect(issue[:hint]).to eq("Use: /Added/, /Removed/, /Fixed/.")
      end
    end
  end
end
