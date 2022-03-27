# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitAuthorEmail do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_author_email)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Author Email")
    end
  end

  describe "#valid?" do
    context "with valid email" do
      let(:commit) { GitPlus::Commit[author_email: "test@example.com"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with invalid email" do
      let(:commit) { GitPlus::Commit[author_email: "bogus"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[author_email: "test@example.com"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[author_email: "bogus"] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq(%(Use "<name>@<server>.<domain>" instead of "bogus".))
      end
    end
  end
end
