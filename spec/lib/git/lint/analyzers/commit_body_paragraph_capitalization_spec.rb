# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyParagraphCapitalization do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_body_paragraph_capitalization")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Paragraph Capitalization")
    end
  end

  describe "#valid?" do
    context "with uppercase paragraph" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII doc audio" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["audio::https://test.io/test.flac[]"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII doc image" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["image::https://test.io/test.png[]"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII doc link" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["link:https://test.io[Test]"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII doc video" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["video::https://test.io/test.mp4[]"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with ASCII doc xref" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["xref:test-1"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with empty paragraphs" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: []] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with blank paragraphs" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["", ""]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with commented paragraphs" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["# One", "# Two"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with lowercase paragraph" do
      let(:commit) { Gitt::Models::Commit[body_paragraphs: ["test."]] }

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
          body_lines: [
            "an invalid paragraph.",
            "which has",
            "multiple lines."
          ],
          body_paragraphs: ["an invalid paragraph.\nwhich has\nmultiple lines."]
        ]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Capitalize first word.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(
          number: 3, content: "an invalid paragraph.\nwhich has\nmultiple lines."
        )
      end
    end
  end
end
