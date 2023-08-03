# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerOrder do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  let :trailers do
    [
      Gitt::Models::Trailer.for("Co-authored-by: River Tam <river@firefly.com>"),
      Gitt::Models::Trailer.for("Issue: 123"),
      Gitt::Models::Trailer.for("Milestone: patch")
    ]
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_trailer_order")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Order")
    end
  end

  describe "#valid?" do
    context "with alphabetical order" do
      let(:commit) { Gitt::Models::Commit[body_lines: [], trailers:] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "without alphabetical order" do
      let(:commit) { Gitt::Models::Commit[body_lines: [], trailers: trailers.reverse] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[body_lines: [], trailers:] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { Gitt::Models::Commit[body_lines: [], trailers: trailers.reverse] }

      it "answers issue" do
        expect(issue).to eq(
          hint: "Ensure keys are alphabetically sorted.",
          lines: [
            {content: "Milestone: patch", number: 3},
            {content: "Co-authored-by: River Tam <river@firefly.com>", number: 5}
          ]
        )
      end
    end
  end
end
