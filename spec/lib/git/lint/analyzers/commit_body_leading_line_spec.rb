# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyLeadingLine do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_leading_line)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Leading Line")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let(:commit) { GitPlus::Commit[message: "Subject\n\nBody.\n"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with subject only" do
      let(:commit) { GitPlus::Commit[message: "Subject"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with subject and no body" do
      let(:commit) { GitPlus::Commit[message: "Subject\n\n"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with subject and comments" do
      let(:commit) { GitPlus::Commit[message: "Subject\n\n# Comment.\n"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with no space between subject and body" do
      let(:commit) { GitPlus::Commit[message: "Subject\nBody\n"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with no content" do
      let(:commit) { GitPlus::Commit[message: ""] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[message: "Subject\n\nBody.\n"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[message: "Subject\nBody."] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use blank line between subject and body.")
      end
    end
  end
end
