# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerCollaboratorKey do
  subject(:analyzer) { described_class.new commit: commit }

  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "abc", shell: shell),
                  trailer_lines: trailer_lines,
                  trailer_index: 2
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_trailer_collaborator_key)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Collaborator Key")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error,
        includes: ["Co-Authored-By"]
      )
    end
  end

  describe "#valid?" do
    context "with no matching key" do
      let(:trailer_lines) { ["Unknown: value"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with valid key only" do
      let(:trailer_lines) { ["Co-Authored-By:"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with valid key and value" do
      let(:trailer_lines) { ["Co-Authored-By: Test Example <test@example.com>"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with invalid key only" do
      let(:trailer_lines) { ["Co-authored-by:"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with invalid key and value" do
      let(:trailer_lines) { ["Co-authored-by: Test Example <test@example.com>"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:trailer_lines) { ["Co-Authored-By: Test Example <test@example.com>"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:trailer_lines) { ["Co-authored-By: Test Example <test@example.com>"] }

      it "answers issue" do
        expect(issue).to eq(
          hint: "Use format: /Co-Authored-By/.",
          lines: [
            {
              content: "Co-authored-By: Test Example <test@example.com>",
              number: 4
            }
          ]
        )
      end
    end
  end
end
