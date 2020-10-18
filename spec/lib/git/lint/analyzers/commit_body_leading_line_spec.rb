# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyLeadingLine do
  subject(:analyzer) { described_class.new commit: commit, settings: settings }

  let(:raw_body) { "Added documentation.\n\n- Necessary for testing purposes.\n" }
  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell), raw_body: raw_body
  end

  let(:settings) { {enabled: true} }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_leading_line)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Leading Line")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error
      )
    end
  end

  describe "#valid?" do
    context "when valid" do
      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with subject only" do
      let(:raw_body) { "A commit message." }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with subject and no body" do
      let(:raw_body) { "A test subject.\n\n" }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with subject and comments" do
      let(:raw_body) { "Subject\n\n# Comment.\n" }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with no space between subject and body" do
      let(:raw_body) { "Subject\nBody\n" }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with no content" do
      let(:raw_body) { "" }

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
      let(:raw_body) { "A commit message.\nWithout leading line." }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use blank line between subject and body.")
      end
    end
  end
end
