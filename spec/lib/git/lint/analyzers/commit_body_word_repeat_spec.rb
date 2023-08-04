# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyWordRepeat do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_body_word_repeat")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Word Repeat")
    end
  end

  describe "#valid?" do
    context "with valid body" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["This is a test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with comments only" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["# This is is a test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "when invalid with single line" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["This is is a test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "when invalid with multiple lines" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: ["This is a test.", "This is invalid invalid.", "End end."]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with empty body" do
      let(:commit) { Gitt::Models::Commit[body_lines: []] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["This is a test."]] }

      it "answers empty string" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        Gitt::Models::Commit[
          body: "This is is a test.\nOne one more time.",
          body_lines: ["This is is a test.", "One one more time."]
        ]
      end

      it "answres issue hint" do
        expect(issue).to eq(
          hint: %(Avoid repeating these words: ["is", "one"].),
          lines: [
            {content: "This is is a test.", number: 3},
            {content: "One one more time.", number: 4}
          ]
        )
      end
    end
  end
end
