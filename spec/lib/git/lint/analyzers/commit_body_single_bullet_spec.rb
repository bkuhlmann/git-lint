# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodySingleBullet do
  subject(:analyzer) { described_class.new commit: commit }

  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell), body_lines: body_lines
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_single_bullet)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Single Bullet")
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
    context "with multiple bullets" do
      let(:body_lines) { ["- Line one.", "- Line two."] }

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

    context "with single bullet (indented)" do
      let(:body_lines) { ["  - Line one."] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with single bullet (no trailing space)" do
      let(:body_lines) { ["-Test bullet."] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with single bullet" do
      let(:body_lines) { ["- Test bullet."] }

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
      let(:body_lines) { ["- A lone bullet."] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use paragraph instead of single bullet.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(number: 2, content: "- A lone bullet.")
      end
    end
  end
end
