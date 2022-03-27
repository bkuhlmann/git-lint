# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyParagraphCapitalization do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

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

  describe "#valid?" do
    context "with uppercase paragraph" do
      let(:commit) { GitPlus::Commit[body_paragraphs: ["Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with empty paragraphs" do
      let(:commit) { GitPlus::Commit[body_paragraphs: []] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with lowercase paragraph" do
      let(:commit) { GitPlus::Commit[body_paragraphs: ["test."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[body_paragraphs: ["Test."]] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        GitPlus::Commit[body_paragraphs: ["an invalid paragraph.\nwhich has\nmultiple lines."]]
      end

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
