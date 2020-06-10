# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyParagraphCapitalization do
  subject(:analyzer) { described_class.new commit: commit }

  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell),
                  body_paragraphs: body_paragraphs
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_paragraph_capitalization)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Paragraph Capitalization")
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
    context "with uppercase paragraph" do
      let(:body_paragraphs) { ["A test paragraph."] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with empty paragraphs" do
      let(:body_paragraphs) { [] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with lowercase paragraph" do
      let(:body_paragraphs) { ["a test paragraph."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:body_paragraphs) { [] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:body_paragraphs) { ["an invalid paragraph.\nwhich has\nmultiple lines."] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Capitalize first word.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(
          number: 2, content: "an invalid paragraph.\nwhich has\nmultiple lines."
        )
      end
    end
  end
end
