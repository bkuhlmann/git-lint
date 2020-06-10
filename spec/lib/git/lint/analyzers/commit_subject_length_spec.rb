# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSubjectLength do
  subject(:analyzer) { described_class.new commit: commit, settings: settings }

  let(:content) { "Added test subject." }
  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell), subject: content
  end

  let(:length) { 25 }
  let(:settings) { {enabled: true, length: length} }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_subject_length)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Subject Length")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error,
        length: 72
      )
    end
  end

  describe "#valid?" do
    context "when valid" do
      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with invalid content" do
      let(:content) { "Curabitur eleifend wisi iaculis ipsum." }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with fixup prefix and max subject length" do
      let(:content) { "fixup! Curabitur eleifend wisix." }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with squash prefix and max subject length" do
      let(:content) { "squash! Curabitur eleifend wisix." }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with invalid length" do
      let(:length) { 10 }

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
      let(:length) { 10 }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use 10 characters or less.")
      end
    end
  end
end
