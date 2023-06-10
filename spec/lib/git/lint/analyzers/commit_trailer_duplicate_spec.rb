# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerDuplicate do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_trailer_duplicate")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Duplicate")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let :commit do
        Gitt::Models::Commit[body_lines: [], trailers: [Gitt::Models::Trailer.for("Issue: 123")]]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with no matching key" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Unknown: value")]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "when unique" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [
            Gitt::Models::Trailer.for("Issue: 123"),
            Gitt::Models::Trailer.for("Issue: 456")
          ]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "when duplicated" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [
            Gitt::Models::Trailer.for("Issue: 123"),
            Gitt::Models::Trailer.for("Issue: 123")
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
        Gitt::Models::Commit[body_lines: [], trailers: [Gitt::Models::Trailer.for("Issue: 123")]]
      end

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [
            Gitt::Models::Trailer.for("Tracker: Linear"),
            Gitt::Models::Trailer.for("Tracker: Linear"),
            Gitt::Models::Trailer.for("Issue: 123"),
            Gitt::Models::Trailer.for("Issue: 456"),
            Gitt::Models::Trailer.for("Issue: 456")
          ]
        ]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: "Avoid duplicates.",
          lines: [
            {number: 3, content: "Tracker: Linear"},
            {number: 4, content: "Tracker: Linear"},
            {number: 6, content: "Issue: 456"},
            {number: 7, content: "Issue: 456"}
          ]
        )
      end
    end
  end
end
