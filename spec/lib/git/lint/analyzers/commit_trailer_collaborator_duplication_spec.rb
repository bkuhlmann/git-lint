# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerCollaboratorDuplication do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_trailer_collaborator_duplication)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Collaborator Duplication")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let :commit do
        GitPlus::Commit[trailers: ["Co-Authored-By: Test One <one@example.com>"]]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with no matching key" do
      let(:commit) { GitPlus::Commit[trailers: ["Unknown: value"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with unique trailers" do
      let :commit do
        GitPlus::Commit[
          trailers: [
            "Co-Authored-By: Test One <one@example.com>",
            "Co-Authored-By: Test Two <two@example.com>"
          ]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with duplicate trailers" do
      let :commit do
        GitPlus::Commit[
          trailers: [
            "Co-Authored-By: Test Example <test@example.com>",
            "Co-Authored-By: Test Example <test@example.com>"
          ]
        ]
      end

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let :commit do
        GitPlus::Commit[trailers: ["Co-Authored-By: Test One <one@example.com>"]]
      end

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        GitPlus::Commit[
          trailers: [
            "Co-Authored-By: Test One <one@example.com>",
            "Co-Authored-By: Test Two <two@example.com>",
            "Co-Authored-By: Test Two <two@example.com>"
          ],
          trailers_index: 2
        ]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: "Avoid duplication.",
          lines: [
            {number: 5, content: "Co-Authored-By: Test Two <two@example.com>"},
            {number: 6, content: "Co-Authored-By: Test Two <two@example.com>"}
          ]
        )
      end
    end
  end
end
