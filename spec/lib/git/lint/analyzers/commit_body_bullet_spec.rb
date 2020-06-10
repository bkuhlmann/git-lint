# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyBullet do
  subject(:analyzer) { described_class.new commit: commit }

  let(:body_lines) { ["- Test message."] }
  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell), body_lines: body_lines
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_bullet)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Bullet")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error,
        excludes: %w[\\* •]
      )
    end
  end

  describe "#valid?" do
    it "answers true when valid" do
      expect(analyzer.valid?).to eq(true)
    end

    context "without bullet" do
      let(:body) { "Test message." }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with empty lines" do
      let(:body_lines) { ["", " ", "\n"] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with excluded bullet" do
      let(:body_lines) { ["* Test message."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded bullet followed by multiple spaces" do
      let(:body_lines) { ["•   Test message."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded, indented bullet" do
      let(:body_lines) { ["  • Test message."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :body_lines do
        [
          "* Invalid bullet.",
          "- Valid bullet.",
          "• Invalid bullet."
        ]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Avoid: /\\*/, /•/.")
      end

      it "answers issue lines" do
        expect(issue[:lines]).to eq(
          [
            {number: 2, content: "* Invalid bullet."},
            {number: 4, content: "• Invalid bullet."}
          ]
        )
      end
    end
  end
end
