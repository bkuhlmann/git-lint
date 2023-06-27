# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerMilestoneKey do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_trailer_milestone_key")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Milestone Key")
    end
  end

  describe "#valid?" do
    context "with valid key and value" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Milestone: patch")]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with valid key and invalid value" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Milestone: #\{$%}")]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with valid key only" do
      let :commit do
        Gitt::Models::Commit[body_lines: [], trailers: [Gitt::Models::Trailer.for("Milestone:")]]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with invalid key only" do
      let :commit do
        Gitt::Models::Commit[body_lines: [], trailers: [Gitt::Models::Trailer.for("milestone:")]]
      end

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with no matching key" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [
            Gitt::Models::Trailer.for("unknown: value")
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
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [
            Gitt::Models::Trailer.for("Milestone: patch")
          ]
        ]
      end

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        Gitt::Models::Commit[body_lines: [], trailers: [Gitt::Models::Trailer.for("milestone: no")]]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: "Use: /Milestone/.",
          lines: [
            {
              content: "milestone: no",
              number: 3
            }
          ]
        )
      end
    end
  end
end
