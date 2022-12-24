# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSignature do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_signature)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Signature")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let(:commit) { Gitt::Models::Commit[signature: "G"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "when invalid" do
      let(:commit) { Gitt::Models::Commit[signature: "B"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[signature: "G"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { Gitt::Models::Commit[signature: "B"] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use: /Good/, /Invalid/.")
      end
    end
  end
end
