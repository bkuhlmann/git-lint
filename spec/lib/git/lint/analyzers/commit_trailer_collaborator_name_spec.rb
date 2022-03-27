# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerCollaboratorName do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_trailer_collaborator_name)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Collaborator Name")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let :commit do
        GitPlus::Commit[trailers: ["Co-Authored-By: Test Example <test@example.com>"]]
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

    context "with custom minimum" do
      subject :analyzer do
        described_class.new GitPlus::Commit[trailers: ["Co-Authored-By: Test <test@example.com>"]]
      end

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[id: :commit_trailer_collaborator_name, minimum: 1]
          ]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with missing email" do
      let(:commit) { GitPlus::Commit[trailers: ["Co-Authored-By: Test Example"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with missing name" do
      let(:commit) { GitPlus::Commit[trailers: ["Co-Authored-By: <test@example.com>"]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
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
        GitPlus::Commit[trailers: ["Co-Authored-By: <test@example.com>"], trailers_index: 2]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: "Name must follow key and consist of 2 parts (minimum).",
          lines: [
            {
              content: "Co-Authored-By: <test@example.com>",
              number: 4
            }
          ]
        )
      end
    end
  end
end
