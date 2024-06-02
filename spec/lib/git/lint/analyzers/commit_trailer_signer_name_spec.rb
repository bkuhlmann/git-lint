# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerSignerName do
  using Refinements::Struct

  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_trailer_signer_name")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Signer Name")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: Test Example <test@example.com>")]
        ]
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

    it "answers true with custom minimum" do
      analyzer = described_class.new(
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: Test <test@example.com>")]
        ],
        settings: settings.merge(commits_trailer_signer_name_minimum: 1)
      )

      expect(analyzer.valid?).to be(true)
    end

    context "with missing email" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: Test Example")]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with missing name" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: <test@example.com>")]
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
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: Test Example <test@example.com>")]
        ]
      end

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: <test@example.com>")]
        ]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: "Name must follow key and consist of 2 parts (minimum).",
          lines: [
            {
              content: "Signed-off-by: <test@example.com>",
              number: 3
            }
          ]
        )
      end
    end
  end
end
