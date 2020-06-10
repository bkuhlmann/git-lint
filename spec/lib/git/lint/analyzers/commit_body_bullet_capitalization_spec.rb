# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyBulletCapitalization do
  subject(:analyzer) { described_class.new commit: commit }

  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell), body_lines: body_lines
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_bullet_capitalization)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Bullet Capitalization")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error,
        includes: %w[\\-]
      )
    end
  end

  describe "#valid?" do
    context "with uppercase bullet" do
      let(:body_lines) { ["- Test bullet."] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with no bullet lines" do
      let(:body_lines) { ["a test line."] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with empty lines" do
      let(:body_lines) { [] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with lowercase bullet (no trailing space)" do
      let(:body_lines) { ["-test bullet."] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with lowercase bullet" do
      let(:body_lines) { ["- test bullet."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with lowercase bullet (indented)" do
      let(:body_lines) { ["  - test bullet."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:body_lines) { [] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:body_lines) { ["Examples:", "- a bullet.", "- Another bullet."] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Capitalize first word.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(number: 3, content: "- a bullet.")
      end
    end
  end
end
