# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitAuthorName do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_author_name)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Author Name")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let(:commit) { GitPlus::Commit[author_name: "Test Example"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with invalid name" do
      let(:commit) { GitPlus::Commit[author_name: "Bogus"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with custom minimum" do
      subject(:analyzer) { described_class.new GitPlus::Commit[author_name: "Example"] }

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[id: :commit_author_name, minimum: 1]
          ]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[author_name: "Example Tester"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[author_name: "Bogus"] }

      it "answers issue hint" do
        hint = "Author name must consist of 2 parts (minimum)."
        expect(issue[:hint]).to eq(hint)
      end
    end
  end
end
