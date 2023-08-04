# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSubjectWordRepeat do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_subject_word_repeat")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Subject Word Repeat")
    end
  end

  describe "#valid?" do
    context "with valid subject" do
      let(:commit) { Gitt::Models::Commit[subject: "Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with empty subject" do
      let(:commit) { Gitt::Models::Commit.new subject: "" }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with no subject" do
      let(:commit) { Gitt::Models::Commit.new }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[subject: "Added specs"] }

      it "answers empty string" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { Gitt::Models::Commit[subject: "Added specs specs"] }

      it "answres issue hint" do
        expect(issue[:hint]).to eq(%(Avoid repeating these words: ["specs"].))
      end
    end
  end
end
