# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerSignerEmail do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_trailer_signer_email)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Signer Email")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-By: Test Example <test@example.com>")]
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

    context "with malformed email address" do
      let :commit do
        Gitt::Models::Commit[
          body_lines: [],
          trailers: [Gitt::Models::Trailer.for("Signed-By: Test Example <invalid>")]
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
          trailers: [Gitt::Models::Trailer.for("Signed-By: Test Example <test@example.com>")]
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
          trailers: [Gitt::Models::Trailer.for("Signed-By: Test Example <invalid>")]
        ]
      end

      it "answers issue" do
        expect(issue).to eq(
          hint: %(Email must follow name and use format: "<name@server.domain>".),
          lines: [
            {
              content: "Signed-By: Test Example <invalid>",
              number: 3
            }
          ]
        )
      end
    end
  end
end
