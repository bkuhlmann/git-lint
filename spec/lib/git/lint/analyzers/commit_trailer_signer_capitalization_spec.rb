# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerSignerCapitalization do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_trailer_signer_capitalization")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Signer Capitalization")
    end
  end

  describe "#valid?" do
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

    context "with valid capitalization" do
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

    context "with invalid capitalization" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: test <test@example.com>")]
        ]
      end

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with missing name" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: <example.com>")]
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
          trailers: [Gitt::Models::Trailer.for("Signed-off-by: test Example <test@example.com>")]
        ]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: "Name must be capitalized.",
          lines: [
            {
              content: "Signed-off-by: test Example <test@example.com>",
              number: 3
            }
          ]
        )
      end
    end
  end
end
