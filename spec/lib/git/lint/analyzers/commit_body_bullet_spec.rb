# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyBullet do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

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

  describe "#valid?" do
    context "when valid" do
      let(:commit) { GitPlus::Commit[body_lines: ["- Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "without bullet" do
      let(:commit) { GitPlus::Commit[body_lines: ["Test message."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with empty lines" do
      let(:commit) { GitPlus::Commit[body_lines: ["", " ", "\n"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with excluded bullet" do
      let(:commit) { GitPlus::Commit[body_lines: ["* Test message."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with excluded bullet followed by multiple spaces" do
      let(:commit) { GitPlus::Commit[body_lines: ["•   Test message."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with excluded, indented bullet" do
      let(:commit) { GitPlus::Commit[body_lines: ["  • Test message."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[body_lines: ["- Test."]] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        GitPlus::Commit[
          body_lines: [
            "* Invalid bullet.",
            "- Valid bullet.",
            "• Invalid bullet."
          ]
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
