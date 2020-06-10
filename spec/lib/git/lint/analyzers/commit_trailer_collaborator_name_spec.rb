# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitTrailerCollaboratorName do
  subject(:analyzer) { described_class.new commit: commit, settings: settings }

  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "abc", shell: shell),
                  trailer_lines: trailer_lines,
                  trailer_index: 2
  end

  let(:settings) { {enabled: true, minimum: minimum} }
  let(:minimum) { 2 }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_trailer_collaborator_name)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Collaborator Name")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error,
        minimum: 2
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

    context "with valid name" do
      let(:trailer_lines) { ["Co-Authored-By: Test Example <test@example.com>"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with custom minimum" do
      let(:minimum) { 1 }
      let(:trailer_lines) { ["Co-Authored-By: Example <test@example.com>"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with missing email" do
      let(:trailer_lines) { ["Co-Authored-By: Test Example"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with missing name" do
      let(:trailer_lines) { ["Co-Authored-By: <test@example.com>"] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:trailer_lines) { ["Co-Authored-By: Text Example <test@example.com>"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:trailer_lines) { ["Co-Authored-By: <test@example.com>"] }

      it "answers issue" do
        expect(issue).to eq(
          hint: "Name must follow key and consist of 2 parts (minimum).",
          lines: [
            {
              content: "Co-Authored-By: <test@example.com>",
              number: 4
            }
          ]
        )
      end
    end
  end
end
