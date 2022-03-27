# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodySingleBullet do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

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

  describe "#valid?" do
    context "with multiple bullets" do
      let(:commit) { GitPlus::Commit[body_lines: ["- One.", "- Two."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with no bullets" do
      let(:commit) { GitPlus::Commit[body_lines: ["Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with empty lines" do
      let(:commit) { GitPlus::Commit[body_lines: []] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with single bullet (indented)" do
      let(:commit) { GitPlus::Commit[body_lines: ["  - Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with single bullet (no trailing space)" do
      let(:commit) { GitPlus::Commit[body_lines: ["-Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with single bullet" do
      let(:commit) { GitPlus::Commit[body_lines: ["- Test."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[body_lines: ["- One.", "- Two."]] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[body_lines: ["- Test."]] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use paragraph instead of single bullet.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(number: 2, content: "- Test.")
      end
    end
  end
end
