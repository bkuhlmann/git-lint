# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerCollaboratorCapitalization do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_trailer_collaborator_capitalization)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Collaborator Capitalization")
    end
  end

  describe "#valid?" do
    context "with no matching key" do
      let(:commit) { GitPlus::Commit[trailers: ["Unknown: value"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with valid capitalization" do
      let :commit do
        GitPlus::Commit[trailers: ["Co-Authored-By: Test Example <test@example.com>"]]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with invalid capitalization" do
      let(:commit) { GitPlus::Commit[trailers: ["Co-Authored-By: test <test@example.com>"]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with missing name" do
      let(:commit) { GitPlus::Commit[trailers: ["Co-Authored-By: <example.com>"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let :commit do
        GitPlus::Commit[trailers: ["Co-Authored-By: Test Example <test@example.com>"]]
      end

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        GitPlus::Commit[
          trailers: ["Co-Authored-By: Test example <test@example.com>"],
          trailers_index: 2
        ]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: "Name must be capitalized.",
          lines: [
            {
              content: "Co-Authored-By: Test example <test@example.com>",
              number: 4
            }
          ]
        )
      end
    end
  end
end
