# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyParagraphNewLine do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_body_paragraph_new_line")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Paragraph New Line")
    end
  end

  describe "#valid?" do
    context "without new lines" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["One."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with new lines with comments" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["# One.\n#Two.\n# Three."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with indentation" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["One.\n  A.\n  B."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII Doc block" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["----\ntest\n----"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII Doc passthrough block" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["++++\ntest\n++++"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII Doc quote block" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["____\ntest\n____"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII Doc code block" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["[source,ruby]\n---\n1\n----"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with Markdown code block" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["```\ntest\n```"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ordered list" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["1. One\n2. Two"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with unordered list (dots)" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: [". One\n. Two"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with unordered list (stars)" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["* One\n* Two"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with new lines" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["One.\nTwo.\nThree."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["Test."]] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: %w[One. Two. Three.],
          body_paragraphs: ["One.\nTwo.\nThree."]
        ]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Avoid unnecessary new lines.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(
          number: 3, content: "One.\nTwo.\nThree."
        )
      end
    end
  end
end
