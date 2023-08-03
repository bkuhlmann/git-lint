# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerReviewerValue do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_trailer_reviewer_value")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Reviewer Value")
    end
  end

  describe "#valid?" do
    context "with valid key and value" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Reviewer: tana")]
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
          trailers: [Gitt::Models::Trailer.for("Reviewer: bogus")]
        ]
      end

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with valid key and no value" do
      let :commit do
        Gitt::Models::Commit[body_lines: [], trailers: [Gitt::Models::Trailer.for("Reviewer:")]]
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
            Gitt::Models::Trailer.for("Reviewer: tana")
          ]
        ]
      end

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        Gitt::Models::Commit[body_lines: [], trailers: [Gitt::Models::Trailer.for("reviewer: no")]]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: "Use: /clickup/, /github/, /jira/, /linear/, /shortcut/, or /tana/.",
          lines: [
            {
              content: "reviewer: no",
              number: 3
            }
          ]
        )
      end
    end
  end
end
